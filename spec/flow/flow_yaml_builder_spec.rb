require "spec_helper"
module Flow::Cli
  RSpec.describe FlowYamlBuilder do
    before(:each) do
      @builder = FlowYamlBuilder.new
    end

    it 'could generate_normal_steps' do
      @builder.config = {
        language: "android"
      }

      steps = @builder.generate_normal_steps
      expect(steps).to be_a Array
      expect(steps.count).to eq 2

      expect(steps.first[:name]).to eq "init"
      expect(steps.first[:plugin][:name]).to eq "android_init"
    end
  end
end
