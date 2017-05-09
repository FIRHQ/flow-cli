require_relative './ios_build_step_generator'

module Flow::Cli
  class ProjectAnalytics
    attr_accessor :config
    def initialize(config = {})
      # 要 env
      config[:flow_language] = language
      self.config = config
    end

    def language
      case platform
      when "ios"
        "objc"
      when "android"
        "android"
      end
    end

    def platform
      raise ConflictPlatformError, "conflict platform" if ios? && android?
      return "ios" if ios?
      return "android" if android?
      raise ConflictPlatformError, "conflict, unknown platform"
    end

    private

    def ios?
      (Dir["#{base_path}*.xcodeproj"] + Dir["#{base_path}*.xcworkspace"]).count > 0
    end

    def android?
      Dir["#{base_path}*.gradle"].count > 0
    end

    def base_path
      return './' if config.nil?
      config[:workspace] || './'
    end
  end
end
