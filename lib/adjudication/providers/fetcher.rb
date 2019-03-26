require 'httparty'

module Adjudication
  module Providers
    class Fetcher
      def provider_data
        # STEP 1: Import Provider CSV data and return it.

        url = 'http://provider-data.beam.dental/beam-network.csv'
        response = HTTParty.get(url)

        if response.code.to_i == 200 # HTTP Response Code
          prov_data = response.parsed_response # nested arrays
        else
          raise "Error fetching Provider data - HTTP Code: " + response.code.to_s
        end

        prov_data
      end

      def filter_data prov_data
      end
    end
  end
end