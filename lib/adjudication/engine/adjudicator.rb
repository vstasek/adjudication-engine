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
        # STEP 5: implement adjudication rules, and add any processed claims (regardless
        # of status) into the processed_claims attribute.
      end
    end
  end
end
