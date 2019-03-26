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
        # STEP 2: Filter invalid NPIS from provider data

        # Remove Provider rows with nil NPIs
        prov_data.select! { |prov_hash| not prov_hash["NPI"].nil? }

        # Allow only numeric NPIs of length 10
        prov_data.each { |prov_hash|
          if not prov_hash["NPI"].scan(/\D/).empty?
            STDERR.puts "Invalid Provider NPI (Only numeric NPIs allowed): " + prov_hash["NPI"]
            prov_hash["delete"] = "Y" # mark for deletion AFTER loop is finished
          elsif not prov_hash["NPI"].length == 10
            STDERR.puts "Invalid Provider NPI (NPI length must = 10): " + prov_hash["NPI"]
            prov_hash["delete"] = "Y"
          end
        }

        prov_data.delete_if {|prov_hash| prov_hash["delete"] == "Y" }
      end
    end
  end
end