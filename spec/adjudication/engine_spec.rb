require "spec_helper"

RSpec.describe Adjudication::Engine do
  it "has a version number" do
    expect(Adjudication::Engine::VERSION).not_to be nil
  end

  describe Adjudication::Engine::Adjudicator do
    def claim(params = {})
      defaults = {
        "npi" => "1811052616",
        "in_network" => true,
        "number" => "2017-09-01-123214",
        "start_date" => "2017-09-01",

        "subscriber" => {
          "ssn" => "000-11-7777",
          "group_number" => "US00123"
        },
        "patient" => {
          "ssn" => "000-12-5555",
          "relationship" => "spouse"
        },
        "line_items" => [
          {
            "procedure_code" => "D1110",
            "tooth_code" => nil,
            "charged" => 100
          }
        ]
      }

      Adjudication::Engine::Claim.new(defaults.merge(params))
    end

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
      how_many = claims_data.count { |claim| claim["in_network"] == true }

      expect(how_many).to be 2
    end

    it "rejects out of network claims" do
      claim = claim("in_network" => false)
      adjudicator = Adjudication::Engine::Adjudicator.new

      processed_claims = adjudicator.adjudicate(claim)
      claim_line = processed_claims[0].line_items[0]

      expect(claim_line.status_code).to eq("R")
    end
    
    it "rejects duplicate claims" do
      claimOne = claim()
      claimTwo = claim()
      adjudicator = Adjudication::Engine::Adjudicator.new

      adjudicator.adjudicate(claimOne)
      processed_claims = adjudicator.adjudicate(claimTwo)
      claim_line_one = processed_claims[0].line_items[0]
      claim_line_two = processed_claims[1].line_items[0]

      expect(claim_line_one.status_code).to eq("P")
      expect(claim_line_two.status_code).to eq("R")
    end

    it "rejects invalid line items" do
      claim = claim("line_items" => [
        {
          "procedure_code" => "D2200"
        }
      ])
      
      expect(claim.line_items[0].ortho?).to be false
      expect(claim.line_items[0].preventive_and_diagnostic?).to be false

      adjudicator = Adjudication::Engine::Adjudicator.new
      processed_claims = adjudicator.adjudicate(claim)
      claim_line = processed_claims[0].line_items[0]

      expect(claim_line.status_code).to eq("R")
    end

    it "pays preventive and diagnostic line items at 100%" do
      claim = claim() # default line item is p&d
      
      expect(claim.line_items[0].preventive_and_diagnostic?).to be true

      adjudicator = Adjudication::Engine::Adjudicator.new
      processed_claims = adjudicator.adjudicate(claim)
      claim_line = processed_claims[0].line_items[0]

      expect(claim_line.status_code).to eq("P")
      expect(claim_line.patient_paid).to eq(0)
    end

    it "pays orthodontic line items at 25%" do
      claim = claim("line_items" => [
        {
          "procedure_code" => "D8090",
          "charged" => 100
        }
      ])
      
      expect(claim.line_items[0].ortho?).to be true

      adjudicator = Adjudication::Engine::Adjudicator.new
      processed_claims = adjudicator.adjudicate(claim)
      claim_line = processed_claims[0].line_items[0]

      expect(claim_line.status_code).to eq("P")
      expect(claim_line.patient_paid).to eq(75)
    end
  end
end