module Flow::Cli
  class Commander
    def build_yaml_file
      config = ProjectAnalytics.new.config
      str = FlowYamlBuilder.new(config).build_yaml
      File.open("flow.ci.yml", "wb") do |file|
        file.write(str)
      end
    end
  end
end
