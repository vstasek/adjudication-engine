#require 'net/http'
require 'httparty'


module Adjudication
  module Providers
    class Fetcher
      def provider_data
        # STEP 1: Import CSV data and return it.

        url = 'http://provider-data.beam.dental/beam-network.csv'
        response = HTTParty.get(url)
        #puts response.parsed_response

      end
    end
  end
end
