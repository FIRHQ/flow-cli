module Flow::Cli
  class BaseException < StandardError
  end

  class ConflictPlatformError < BaseException
  end

  class YamlError < BaseException
  end

  class ParamsError < BaseException
  end

  class FlowApiError < BaseException
  end
end
