require "adjudication/engine/version"
require "adjudication/providers"
require "adjudication/engine/adjudicator"
require "adjudication/engine/claim"

module Adjudication
  module Engine
    def self.run claims_data
      fetcher = Adjudication::Providers::Fetcher.new
      provider_data = fetcher.provider_data

      # STEP 2: Filter the provider data (filter invalid NPIs)
      # STEP 3: Our claims are in claims_data, an array of hashes
      # STEP 4: Match provider data up to claims data by NPI
      # STEP 5: run the adjudicator (Adjudication::Engine::Adjudicator.adjudicate)
      
      # return the processed claims

      []
    end
  end
end
