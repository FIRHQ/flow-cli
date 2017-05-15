require_relative './flow_yaml_builder'
require_relative './ios_build_step_generator'
require 'yaml'
module Flow::Cli
  module YamlBuilders
    class IosYamlBuilder < FlowYamlBuilder
      def initialize(cli_config = {})
        super
        cli_config[:flow_version] = "Xcode8"
      end

      def generate_custom_build_step
        script = IosBuildStepGenerator.new(flow_cli_config).generate_gym_script
        {
          name: "build",
          scripts: [script]
        }
      end
    end
  end
end
