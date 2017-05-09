require 'yaml'
require 'tty'
module Flow::Cli
  class Commander
    def build_yaml_file
      config = ProjectAnalytics.new.config
      str = FlowYamlBuilder.new(config).build_yaml
      raise YamlError, "存在flow.yml, 删除后才能重新生成" if File.file?(".flow.yml")
      File.open(".flow.yml", "wb") do |file|
        file.write(str)
      end

      puts str
    end

    def select_yml_steps(step_name)
      raise YamlError, "Can not found .flow.yml" unless File.file?(".flow.yml")
      dict = YAML.safe_load(File.read(".flow.yml"))

      the_steps = []
      dict["flows"].map do |flow|
        filtered_steps = flow["steps"].select { |step| step["name"] == step_name }
        the_steps += filtered_steps
      end
      the_steps
    end

    def get_scripts(steps)
      scripts = []
      steps.each do |step|
        next if step["scripts"].nil?
        scripts += step["scripts"]
      end
      scripts
    end

    def run_script(script)
      cmd = TTY::Command.new
      cmd.run(script)
    end

    def try_run_yml_build_script
      scripts = get_scripts(select_yml_steps("build"))
      run_script(scripts.first)
    end
  end
end
