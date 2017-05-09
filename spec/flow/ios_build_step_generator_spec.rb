require "spec_helper"
module Flow::Cli
  RSpec.describe IosBuildStepGenerator do
    before(:each) do
      File.delete("test.xcodeproj") if File.file?("test.xcodeproj")
      File.delete("test.xcworkspace") if File.file?("test.xcworkspace")
    end

    it "could config ios project platform" do
      expect(IosBuildStepGenerator.new({}).generate_gym_script).to eq "fastlane gym build --export_method ad-hoc"
    end
  end
end
