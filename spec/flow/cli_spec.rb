require "spec_helper"

RSpec.describe Flow::Cli do
  it "has a version number" do
    expect(Flow::Cli::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
