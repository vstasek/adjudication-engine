require "adjudication/engine/version"
require "adjudication/providers"
require "adjudication/engine/adjudicator"
require "adjudication/engine/claim"

module Adjudication
  module Engine
    def self.run claims_data
      fetcher = Adjudication::Providers::Fetcher.new
      prov_data = fetcher.provider_data # STEP 1
      prov_data = fetcher.filter_data(prov_data) # STEP 2

      # STEP 3: Our claims are already in claims_data (from ARGV[0])

      adjudicator = Adjudication::Engine::Adjudicator.new
      adjudicator.matchNPI(claims_data, prov_data) # STEP 4

      # STEP 5: run the adjudicator
      adjudicator = Adjudication::Engine::Adjudicator.new
      claims_data.each do |claim_hash|
        claim = Adjudication::Engine::Claim.new claim_hash
        adjudicator.adjudicate(claim)
      end

      adjudicator.processed_claims
    end
  end
end
