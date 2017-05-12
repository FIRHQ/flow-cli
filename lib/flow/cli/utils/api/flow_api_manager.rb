require_relative "../flow_api_rest"
module Flow::Cli
  module Utils
    class FlowApiManager
      attr_accessor :email, :password, :user_access_token, :current_org_id,
                    :current_project_id, :current_flow_id,
                    :current_project_name
      def initialize(hash = {})
        %i[email password user_access_token].each do |item|
          send "item=", hash[item]
        end
        yield self if block_given?
        init_access_token if user_access_token.nil?
      end

      def fetch_projects(specify_org = nil)
        org_id = specify_org || current_org_id
        FlowApiRest.get("/projects", access_token: user_access_token, org_id: org_id)
      end

      private

      def init_access_token
        answer = self.class.login(email, password)
        self.user_access_token = answer[:access_token]
      end

      class << self
        def login(email, password)
          dict = FlowApiRest.post("/login", login: email, password: password)
          DbManager.save(login: email, password: password)
          dict
        end

        def load_from_db
          new DbManager.read(hash)
        end
      end
    end
  end
end
