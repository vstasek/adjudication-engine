require "spec_helper"

RSpec.describe Adjudication::Engine do
  it "has a version number" do
    expect(Adjudication::Engine::VERSION).not_to be nil
  end

  describe Adjudication::Engine::Adjudicator do
    it "determines out of network claims" do
      claims_data = [
      {"npi" => "1234567890"}, # In Network
      {"npi" => "1770797672"}, # Out Network
      {"npi" => "6666666666"}, # Out
      {"NoNPI" => ""}, # N/A
      {"npi" => "1112223334", "secondKey" => "abc"} # In
      ]

      prov_data = [
      {"NPI" => "1234567890"}, # Match
      {"NPI" => "1112223334"}, # Match
      {"NPI" => "5555555555"}, # No Match
      {"NPI" => "9517534567"}, # No Match
      {"NPI" => "0007774203"}, # No Match
      ]

      adjudicator = Adjudication::Engine::Adjudicator.new
      adjudicator.matchNPI(claims_data, prov_data)
      how_many  = claims_data.count { |claim| claim["in_network"] == true }

      expect(how_many).to be 2
    end

    it "rejects out of network claims"
    it "rejects duplicate claims"
    it "pays valid line items"
    it "rejects invalid line items"
  end
end