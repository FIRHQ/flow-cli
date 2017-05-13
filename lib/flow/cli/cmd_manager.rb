require 'yaml'
require 'tty'
require 'thor'
require_relative './commands/remote'

module Flow::Cli
  class CmdManager < Thor
    def initialize(*args)
      super(*args)
      @prompt = TTY::Prompt.new
      @pastel = Pastel.new
      @error    = @pastel.red.bold.detach
      @warning  = @pastel.yellow.detach
      @db_manager = Utils::DbManager
      @api_manager = Utils::FlowApiManager.load_from_db
    end

    desc "remote ...ARGS", "manage flow ci"
    subcommand "remote", Commands::Remote

    desc "build_yaml_file", "build flow ci project yaml"
    def build_yaml_file
      config = ProjectAnalytics.new.config
      # 用来交互
      # TODO: 优化点，以后放到其他地方
      config[:gym_config] = ask_gym_build_options if config[:flow_language] == "objc" && ENV["FLOW_CLI_TEST"] != "TRUE"

      str = FlowYamlBuilder.new(config).build_yaml
      raise YamlError, "存在 #{FLOW_YML_NAME}, 删除后才能重新生成" if File.file?(FLOW_YML_NAME)
      File.open(FLOW_YML_NAME, "wb") do |file|
        file.write(str)
      end
      @warning.call "yaml created...\n#{str}"
    end

    desc "run_build_script", "run flow yml build script"
    def run_build_script
      show_build_script
      try_run_yml_build_script
    end

    desc "show_build_script", "show flow yml build script"
    def show_build_script
      script = yml_build_script
      puts @warning.call "This is the build script in yaml"
      print_line
      puts script
      print_line
    end

    desc "version", "show flow cli version #{VERSION}"
    map ['v', '-v', '--version'] => :version
    def version
      puts VERSION
    end

    desc "upgrade", "upgrade flow-cli"
    def upgrade
      run_script "gem install flow-cli"
    end

    desc 'help', 'Describe available commands or one specific command (aliases: `h`).'
    map Thor::HELP_MAPPINGS => :help
    def help(command = nil, subcommand = false)
      print_line
      puts @error.call("VERSION ALPHA\n Support IOS project ONLY, temporarily.")
      print_line
      super
    end

    no_commands do
      def select_yml_steps(step_name)
        raise YamlError, "Can not found flow.yml" unless File.file?(FLOW_YML_NAME)
        dict = YAML.safe_load(File.read(FLOW_YML_NAME))

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

      def yml_build_script
        if File.file?(FLOW_YML_NAME) == false
          return unless @prompt.yes?('no flow.yml found, need to build . y/n')
          build_yaml_file
        end
        scripts = get_scripts(select_yml_steps("build"))
        scripts.first if scripts.count > 0
      end

      def try_run_yml_build_script
        run_script(yml_build_script)
      end

      private

      def print_line
        puts "*" * 30
      end

      def ask_gym_build_options
        user_gym_config = {}
        user_gym_config[:export_method] = @prompt.select("export_method? ", %w[development app-store ad-hoc package enterprise developer-id])
        user_gym_config[:silent] = "" if @prompt.yes?("less log?")

        user_gym_config
      end
    end
  end
end
