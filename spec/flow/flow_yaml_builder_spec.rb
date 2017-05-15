require "spec_helper"
module Flow::Cli
  RSpec.describe YamlBuilders::FlowYamlBuilder do
    before(:each) do
      @builder = YamlBuilders::FlowYamlBuilder.new
    end

    it 'could generate_normal_steps' do
      @builder.flow_cli_config = {
        flow_language: "android"
      }

      steps = @builder.generate_normal_steps
      expect(steps).to be_a Array
      expect(steps.count).to eq 2

      expect(steps.first[:name]).to eq "init"
      expect(steps.first[:plugin][:name]).to eq "android_init"
    end

    it "could generate_custom_build_step " do
      @builder.flow_cli_config = {
        language: "ios"
      }

      step = @builder.generate_custom_build_step
      expect(step[:name]).to eq "build"
      expect(step[:scripts].class).to eq Array
      expect(step[:scripts].first).to eq 'fastlane gym build --export_method ad-hoc'
    end

    it 'could generate_yaml' do
      @builder.flow_cli_config = {
        language: "ios",
        gym_config: {} # stub
      }
      yaml = @builder.build_yaml
      expect(YAML.safe_load(yaml).class).to eq Hash
    end
  end
end
