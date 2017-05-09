require 'fastlane'
require 'gym'

module Flow::Cli
  class IosBuildStepGenerator
    attr_accessor :config
    attr_accessor :debug
    def initialize(default_config = nil)
      if default_config.nil?
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, {})
        config = Gym.config.values(ask: false).reject { |_k, v| v.nil? }
        allowed_params = %i[workspace project sheme clean output_name configuration
                            codesigning_identity include_symbols include_bitcode
                            export_method export_options export_xcargs]
        default_config = config.select { |k, _v| allowed_params.include? k }
      end

      self.config = default_config
    end

    def generate_gym_script(category = 'ad-hoc', force = false)
      set_export_params(category, force)
      "fastlane gym build #{build_gym_params}"
    end

    # 返回 由 gym 调用的 core 的生成的相关参数
    def set_export_params(category = 'ad-hoc', force = false)
      raise ParamsError, "#{category} not exists" unless %w[app-store ad-hoc package enterprise development
                                                            developer-id].include? category
      return config if config[:export_method] && force == false

      config[:export_method] = category
      config
    end

    def build_gym_params
      config.map { |k, v| "--#{k} #{v}" }.join(' ')
    end
  end
end
