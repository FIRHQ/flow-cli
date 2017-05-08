module Flow::Cli
  class FlowYamlBuilder
    attr_accessor :config
    def initialize(config = {})
      self.config = config
    end

    def create_default_flow_dict
      flow = {}

      flow[:name] = config[:name]
      flow[:language] = config[:language]

      flow[:env] = config[:env]
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
      steps << generate_step_dict("init", name: "#{config[:language]}_init")
      steps << generate_step_dict("git")

      steps
    end

    # 生成编译脚本
    def generate_custom_build_step
      # TODO: build custom build step
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
