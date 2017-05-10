require 'fastlane'
require 'gym'

module Flow::Cli
  class IosBuildStepGenerator
    attr_accessor :cli_config
    def initialize(cli_config = {})
      self.cli_config = cli_config
      if ENV["FLOW_CLI_TEST"] != "TRUE"
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, {})
        config = Gym.config.values(ask: false).reject { |_k, v| v.nil? }
        allowed_params = %i[workspace project scheme clean output_name configuration
                            codesigning_identity include_symbols include_bitcode
                            export_method export_options export_xcargs]
        @gym_config = config.select { |k, _v| allowed_params.include? k }
      else
        @gym_config = {}
      end
    end

    def generate_gym_script
      merge_user_cli_gym_config
      "fastlane gym build #{build_gym_params}"
    end

    # 返回 由 gym 调用的 core 的生成的相关参数
    def merge_user_cli_gym_config
      user_gym_config = { export_method: 'ad-hoc' }.merge(cli_config[:gym_config] || {} )
      @gym_config.merge!(user_gym_config)
      @gym_config
    end

    def build_gym_params
      @gym_config.map { |k, v| "--#{k} #{v}" }.join(' ')
    end
  end
end
