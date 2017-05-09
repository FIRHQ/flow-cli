require "spec_helper"
module Flow::Cli
  RSpec.describe ProjectAnalytics do
    before(:each) do
      File.delete("test.xcodeproj") if File.file?("test.xcodeproj")
      File.delete("test.xcworkspace") if File.file?("test.xcworkspace")

      File.delete("test.gradle") if File.file?("test.gradle")
    end

    it "could config ios project platform" do
      FileUtils.touch('test.xcworkspace')
      expect(ProjectAnalytics.new.platform).to eq "ios"

      FileUtils.touch('test.xcodeproj')
      expect(ProjectAnalytics.new.platform).to eq "ios"
    end

    it "could config android project platform" do
      FileUtils.touch('test.gradle')
      expect(ProjectAnalytics.new.platform).to eq "android"
    end

    it "could raise exception when have both project type files" do
      expect do
        ProjectAnalytics.new.platform
      end.to raise_error(ConflictPlatformError)

        FileUtils.touch('test.gradle')
        FileUtils.touch('test.xcodeproj')
      expect do
        ProjectAnalytics.new.platform
      end.to raise_error(ConflictPlatformError)
    end
  end
end
