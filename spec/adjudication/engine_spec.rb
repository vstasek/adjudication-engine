require "spec_helper"

RSpec.describe Adjudication::Engine do
  it "has a version number" do
    expect(Adjudication::Engine::VERSION).not_to be nil
  end

  describe Adjudication::Engine::Adjudicator do
    it "determines out of network claims"
    it "rejects out of network claims"
    it "rejects duplicate claims"
    it "pays valid line items"
    it "rejects invalid line items"
  end
end