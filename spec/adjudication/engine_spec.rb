require "spec_helper"

RSpec.describe Adjudication::Engine do
  it "has a version number" do
    expect(Adjudication::Engine::VERSION).not_to be nil
  end
end

RSpec.describe Adjudication::Providers do
  it "fetches provider data" do
    fetcher = Adjudication::Providers::Fetcher.new
    prov_data = fetcher.provider_data

    # returns an array of hashes (matches claims_data)
    expect(prov_data.class).to eq(Array)
    if prov_data.size > 0
      expect(prov_data[0].class).to eq(Hash)
    end
  end
  
  it "filters invalid NPIs" do
    fetcher = Adjudication::Providers::Fetcher.new
    prov_data = [
      {"NPI" => "1234"}, # too short
      {"NPI" => "5555598765432100"}, # too long
      {"NPI" => "1770797672"}, # just right - PASS
      {"NPI" => "ITSJUSTLETTERS"}, # alphabetic
      {"NPI" => "ABC012DEF3"}, # numeric + alphabetic 
      {"NoNPI" => ""}, # no NPI
      {"NPI" => "1112223334", "secondKey" => "abc"} # PASS
    ]

    prov_data = fetcher.filter_data(prov_data)
    expect(prov_data.size).to eq(2)
  end
end