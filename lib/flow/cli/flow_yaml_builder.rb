module Flow::Cli
  class FlowYamlBuilder
    attr_accessor :flow_cli_config
    def initialize(flow_cli_config = {})
      self.flow_cli_config = flow_cli_config
    end

    def create_default_flow_dict
      flow = {}

      flow[:name] = flow_cli_config[:name]
      flow[:language] = flow_cli_config[:language]

      flow[:env] = flow_cli_config[:env]
      flow[:trigger] = {
        push: %w[develop master]
      }
      flow
    end

    def generate_steps
      steps = []
      generate_normal_steps.each { |step| steps << step }
      steps << generate_custom_build_step
    end

    # 创建一些标准的steps
    def generate_normal_steps
      steps = []
      steps << generate_step_dict("init", name: "#{flow_cli_config[:language]}_init")
      steps << generate_step_dict("git")

      steps
    end

    # 生成编译脚本
    def generate_custom_build_step
      script = IosBuildStepGenerator.generate_gym_script
      {
        name: "build",
        plugin: {
          name: name,
          scripts: [script]
        }
      }
    end

    def generate_step_dict(name, plugin_config = nil)
      step_dict = {
        name: name,
        plugin: {
          name: name
        }
      }
      step_dict[:plugin].merge!(plugin_config) if plugin_config
      step_dict
    end
  end
end
