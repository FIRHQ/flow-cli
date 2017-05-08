module Flow::Cli
  class ProjectAnalytics
    attr_accessor :config
    def initialize(config = {})
      self.config = config
    end

    def platform
      raise "conflict platform" if is_ios? && is_android?
      return "ios" if is_ios?
      return "android" if is_android?
      raise ConflictPlatformError, "unknow platform"
    end

    private

    def is_ios?
      (Dir["#{base_path}*.xcodeproj"] + Dir["#{base_path}*.xcworkspace"]).count > 0
    end

    def is_android?
      Dir["#{base_path}*.gradle"].count > 0
    end

    def base_path
      config[:workspace] || './'
    end
  end
end
