require_relative './local_service_rest'
module Flow::Cli
  module Utils
    class FlowApiRest < LocalServiceRest
      class << self
        def basic_url
          FLOW_API_URL # 子类中复写
        end
      end
    end
  end
end
