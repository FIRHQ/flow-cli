require_relative "../flow_api_rest"
module Flow::Cli
  module Utils
    class FlowApiManager
      class << self
        def login_in(email, password)
          FlowApiRest.post(email, password)
        end
      end
    end
  end
end
