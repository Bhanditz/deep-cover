require "spec_helper"

RSpec.describe TrivialGem do
  it "has a version number" do
    expect(TrivialGem::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(TrivialGem.hello).to eq(:world)
  end

  it "runs a bunch of branches" do
    expect(TrivialGem.branches(1)).to eq(1)
  end
end
