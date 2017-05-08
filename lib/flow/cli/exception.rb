module Flow::Cli
  class BaseException < StandardError
  end

  class ConflictPlatformError < BaseException
  end
end
