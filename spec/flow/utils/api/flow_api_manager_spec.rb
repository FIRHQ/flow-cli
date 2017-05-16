require "spec_helper"
module Flow::Cli
  module Utils
    RSpec.describe FlowApiManager do
      before(:each) do
        pending("you should told me email and password") if ENV["password"].nil? || ENV["email"].nil?
        FlowApiManager.login(ENV["email"], ENV["password"])
        @manager = FlowApiManager.load_from_db
      end

      it 'could init' do
        expect(!@manager.user_access_token.empty?).to eq true
      end

      it 'could read projects' do
        projects = @manager.fetch_projects
        expect(projects.empty?).to eq false
      end

      it 'could read flows and flow' do
        project_id = "56ecf8879b79b2230c000062"
        flows = @manager.fetch_flows(project_id)
        expect(flows.count > 0).to eq true
        flow_id = "57342ca37e77c70aba00001d"
        expect((@manager.fetch_flow flow_id, project_id)[:name].nil?).to eq false
      end
    end
  end
end
