require "spec_helper"
module Flow::Cli
  RSpec.describe CmdManager do
    before(:each) do
      @cmd = CmdManager.new
      File.delete(FLOW_YML_NAME) if File.file?(FLOW_YML_NAME)
      File.delete("test.gradle") if File.file?("test.gradle")
      File.delete("test.xcodeproj") if File.file?("test.xcodeproj")
    end

    it "could run script" do
      answer = @cmd.run_script "echo 'hello world'"
      expect(answer.out).to eq "hello world\n"
    end

    it "could build_yaml_file" do
      FileUtils.touch "test.xcodeproj"
      @cmd.build_yaml_file
      expect(File.file?(FLOW_YML_NAME)).to eq true
    end

    it 'could get_scripts' do
      FileUtils.touch "test.xcodeproj"
      @cmd.build_yaml_file
      scripts = @cmd.get_scripts(@cmd.select_yml_steps("build"))
      expect(scripts.count).to eq 1
      expect(scripts.first).to eq "fastlane gym build --export_method ad-hoc"
    end

    it "could try run script" do
      FileUtils.touch "test.xcodeproj"
      config = ProjectAnalytics.new.config
      str = YamlBuilders::IosYamlBuilder.new(config).build_yaml
      str.gsub!("fastlane gym build --export_method ad-hoc", 'echo "hello world"')

      File.open(FLOW_YML_NAME, "wb") do |file|
        file.write(str)
      end

      cmd_answer = @cmd.try_run_yml_build_script
      expect(cmd_answer.out).to eq "hello world\n"

    end
  end
end
