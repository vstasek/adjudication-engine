module Adjudication
  module Engine
    class Adjudicator
      attr_reader :processed_claims

      def initialize
        @processed_claims = []
      end


      def adjudicate(claim)
        # TODO implement adjudication rules, and add any processed claims (regardless
        # of status) into the processed_claims attribute.
      end
    end
  end
end
