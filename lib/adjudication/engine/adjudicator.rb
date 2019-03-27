module Adjudication
  module Engine
    class Adjudicator
      attr_reader :processed_claims

      def initialize
        @processed_claims = []
      end

      def matchNPI(claims, providers)
        # STEP 4: Match claims data up to provider data by NPI

        # Gives each claim an in_network key
        claims.each do |claim_hash|
          claim_hash["in_network"] = false # default to false

          providers.each do |provider_hash|
            if claim_hash["npi"] == provider_hash["NPI"]
              claim_hash["in_network"] = true
              break
            end
          end
        end

        claims
      end

      def adjudicate(claim)
        # STEP 5: implement adjudication rules

        rejectReason = ""
        if duplicate?(claim)
          rejectReason = "Duplicate Claim"
        elsif !claim.in_network
          rejectReason = "Out of Network Claim"
        end

        # Reject the ENTIRE claim if it's a duplicate OR out of network
        if rejectReason != ""
          claim.line_items.each do |line_item|
            line_item.reject!
            sendtoSTDERR(claim, line_item, rejectReason)
          end
          return @processed_claims << claim
        end

        # Pay valid line items
        claim.line_items.each do |line_item|
          if line_item.ortho?
            line_item.pay!(line_item.charged * 0.25)
          elsif line_item.preventive_and_diagnostic?
            line_item.pay!(line_item.charged)
          else
            line_item.reject!
            rejectReason = "Service is neither orthodontic nor preventative."
            sendtoSTDERR(claim, line_item, rejectReason)
          end
        end

        @processed_claims << claim
      end
    
      private
        def duplicate?(claim)
          # checks claim against @processed_claims to see if claim is a duplicate
          ##
          # EDGE CASE NOTE: Due to the use of Set when comparing claim procedure codes,
          # "duplicate?" will still return true EVEN IF
          # one of the claims has duplicates of a procedure code and the other claim does not.

          # (e.g. 
          # @processed_claims has line item 1:"D1110" & line item 2: "D1110"
          # argument claim has "D1110" - duplicate?(claim) will return true)
          # I'm not sure if it's POSSIBLE for a single claim to have duplicate line item procedure codes.
          # If so, we would need a different implementation for comparing procedure_codes.
          ##

          if @processed_claims.empty?
            return false
          end

          @processed_claims.each do |proc_claim|
            # same start date, patient SSN, and set of procedures codes
            if  proc_claim.start_date == claim.start_date &&
                proc_claim.patient["ssn"] == claim.patient["ssn"] &&
                Set.new(proc_claim.procedure_codes) == Set.new(claim.procedure_codes)

                return true
            end
          end
          false
        end

        def sendtoSTDERR (claim, line_item, reason)
          STDERR.puts "REJECTED LINE ITEM: Claim Number: " + claim.number +
                        " Line Item: " + line_item.procedure_code + " Reject Reason: " + reason
        end
    end
  end
end
