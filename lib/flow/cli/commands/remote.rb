require 'yaml'
require 'byebug'
require 'tty'
require 'thor'

module Flow::Cli
  module Commands
    class Remote < Thor
      def initialize(*args, &proc)
        super(*args)
        @db_manager = Utils::DbManager
        @api_manager = Utils::FlowApiManager.load_from_db(&proc)
        @cmd_helper = Utils::CmdHelper.instance
      end

      desc "login", "bind flow ci account to flow cli."
      def login
        email = @cmd_helpert.ask("email?")
        password = @cmd_helper.mask("password?")
        Utils::FlowApiManager.login(email, password)
        puts "login success"
      end

      desc "reset", "reset flow api info data"
      def reset
        @db_manager.reset
        @cmd_helper.puts_warning "reset ok..."
      end

      desc "project_init", "set a project from flow ci to operation"
      def project_init
        projects = current_api_manager.fetch_projects
        # begin
        #   file_origin = `git remote -v`.to_s.match("git.*.git").first
        # rescue
        #   cmd_helper.puts_warning "read git origin fail..."
        # end

        dict = {}
        dict = Hash[projects.map { |p| [p[:name].to_s, p[:id]] }]

        current_project_id = @cmd_helper.select("Choose your project?", dict)

        @db_manager.save_attribute(:current_project_id, current_project_id)

        flows = current_api_manager.fetch_flows(current_project_id)

        current_flow_id = if flows.count == 1
                            flows.first[:id]
                          else
                            dict = {}
                            flows.each { |p| dict[(p[:name]).to_s] = p[:id] }
                            @cmd_helper.select("Choose your flow?", dict)
                          end
        @db_manager.save_attribute(:current_flow_id, current_flow_id)
        puts "project_id = #{current_project_id}, flow_id = #{current_flow_id}. saved this info..."
      end

      desc "upload_p12 FILE_PATH [p12 password]", "upload_p12"
      def upload_p12(file_path, password = nil)
        choosed_project_check
        basename = File.basename file_path
        project_init unless @db_manager.read_attribute(:current_flow_id)

        api_p12s = current_api_manager.load_p12s(@db_manager.read_attribute(:current_flow_id))
        old_p12 = api_p12s.find { |p12| p12[:filename] == basename }
        unless old_p12.nil?
          if @cmd_helper.yes? "found a same name file, override?"
            current_api_manager.delete_p12(old_p12[:id], @db_manager.read_attribute(:current_flow_id))
          else
            return @cmd_helper.puts_warning "canceled..."
          end
        end
        current_api_manager.upload_p12(@db_manager.read_attribute(:current_flow_id), file_path, password)
        puts "uploaded."
      end

      desc "list_p12s", "list_p12s"
      def list_p12s
        choosed_project_check
        puts current_api_manager.load_p12s(@db_manager.read_attribute(:current_flow_id))
      end

      desc "upload_provision", "upload_provision"
      def upload_provision(file_path)
        choosed_project_check
        basename = File.basename file_path
        project_init unless @db_manager.read_attribute(:current_flow_id)

        api_provisions = current_api_manager.load_provisions(@db_manager.read_attribute(:current_flow_id))
        old_provision = api_provisions.find { |provision| provision[:filename] == basename }
        unless old_provision.nil?
          if @cmd_helper.yes? "found a same name file, override?"
            current_api_manager.delete_provision(old_provision[:id], @db_manager.read_attribute(:current_flow_id))
          else
            return puts "canceled.."
          end
        end
        current_api_manager.upload_provision(@db_manager.read_attribute(:current_flow_id), file_path)
        puts "uploaded."
      end

      desc "list_provisions", "list provisions"
      def list_provisions
        choosed_project_check
        puts current_api_manager.load_provisions(@db_manager.read_attribute(:current_flow_id))
      end

      no_commands do
        private

        def current_api_manager
          return @current_api_manager unless @current_api_manager.nil?
          @api_manager.refresh_login  do
            [@cmd_helper.ask("email?"), @cmd_helper.mask("password?")]
          end
          @current_api_manager = @api_manager
          @current_api_manager
        end

        def choosed_project_check
          project_init if @db_manager.read_attribute(:current_project_id).nil?
        end
      end
    end
  end
end
