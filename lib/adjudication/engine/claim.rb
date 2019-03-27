require "adjudication/engine/claim_line_item"

module Adjudication
  module Engine
    class Claim
      attr_accessor(
        :number,
        :provider,
        :subscriber,
        :patient,
        :start_date,
        :line_items,
        :in_network
      )

      def initialize claim_hash
        @number = claim_hash['number']
        @provider = claim_hash['provider']
        @subscriber = claim_hash['subscriber']
        @patient = claim_hash['patient']
        @start_date = claim_hash['start_date']
        @line_items = claim_hash['line_items'].map{ |x| ClaimLineItem.new(x) }
        @in_network = claim_hash['in_network']
      end

      def procedure_codes
        line_items.map(&:procedure_code)
      end
    end
  end
end
