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

        # Put provider data in same format as claims data for easy comparison
        # Create array containing CSV header columns
        fields = Array.new
        prov_data[0].map { |header_col| fields << header_col}
        prov_data.shift # Remove row containing CSV header cols from provider data

        # Convert Provider prov_data to array of hashes; (same format as claims_data)
        prov_data.map { |row| fields.zip(row).to_h }
      end

      def filter_data prov_data
      end
    end
  end
end