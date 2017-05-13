require_relative "../flow_api_rest"
module Flow::Cli
  module Utils
    class FlowApiManager
      attr_accessor :email, :password, :user_access_token, :current_org_id,
                    :current_project_id, :current_flow_id,
                    :current_project_name

      def initialize(hash = {})
        %i[email password user_access_token].each do |item|
          send "#{item}=", hash[item.to_s]
        end
        yield self if block_given?
        init_access_token if user_access_token.nil?
      end

      def fetch_orgs
        raw_orgs = FlowApiRest.get("/orgs", access_token: user_access_token)
        raw_orgs.map do |org|
          org.slice(:id, :name)
        end
      end

      def fetch_projects(specify_org_id = nil)
        org_id = specify_org_id || current_org_id
        send_to_api(:get, "/projects", { org_id: org_id }, %i[id name git_url source])
      end

      def fetch_project(project_id)
        send_to_api(:get, "/projects/#{project_id}")
      end

      def fetch_flows(project_id)
        send_to_api(:get, "/projects/#{project_id}/flows")
      end

      # 5909e8c4ef2cb07bcefc3dbd
      def upload_p12(flow_id, file, password = nil)
        send_to_api(:post, "/flows/#{flow_id}/certificates",
                    file: standard_file(file),
                    type: "ios",
                    password: password)
      end

      def load_p12s(flow_id)
        send_to_api(:get, "/flows/#{flow_id}/certificates")
      end

      def delete_p12(p12_id, flow_id)
        send_to_api(:delete, "/certificates/#{p12_id}", flow_id: flow_id)
      end

      def upload_provision(flow_id, file)
        send_to_api(:post, "/flows/#{flow_id}/mobileprovisions",
                    file: standard_file(file),
                    flow_id: flow_id)
      end

      def load_provisions(flow_id)
        send_to_api(:get, "/flows/#{flow_id}/mobileprovisions")
      end

      def delete_provision(mobileprovisions_id,flow_id)
        send_to_api(:delete, "/mobileprovisions/#{mobileprovisions_id}", flow_id: flow_id)
      end

      def fetch_flow(flow_id, project_id)
        send_to_api(:get, "/flows/#{flow_id}", project_id: project_id)
      end

      def send_to_api(action, url, params = {}, slice_items = nil, need_access_token = true)
        params[:access_token] = user_access_token if need_access_token
        params.compact!
        raw_answer = FlowApiRest.send(action, url, params)

        return raw_answer if slice_items.nil?
        raise "slice need be a array with symbols" unless slice_items.is_a? Array

        return raw_answer.map { |item| item.slice(*slice_items) } if raw_answer.is_a? Array
        raw_answer.slice(*slice_items)
      end

      def init_access_token
        answer = self.class.login(email, password)
        self.user_access_token = answer[:access_token]
      end

      def standard_file(file)
        return File.open(file) if file.is_a?(String)
        file
      end

      class << self
        def login(email, password)
          dict = FlowApiRest.post("/login", login: email, password: password)
          DbManager.save(email: email, password: password)
          dict
        end

        def load_from_db
          new(DbManager.read)
        end
      end
    end
  end
end
