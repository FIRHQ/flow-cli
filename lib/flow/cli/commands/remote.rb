require 'yaml'
require 'tty'
require 'thor'

module Flow::Cli
  module Commands
    class Remote < Thor

      def initialize(*args)
        super(*args)
        @prompt = TTY::Prompt.new
        @pastel = Pastel.new
        @error    = @pastel.red.bold.detach
        @warning  = @pastel.yellow.detach
        @db_manager = Utils::DbManager
        @api_manager = Utils::FlowApiManager.load_from_db
      end

      desc "login", "bind flow ci account to flow cli."
      def login
        email = @prompt.ask("email?")
        password = @prompt.mask("password?")
        Utils::FlowApiManager.login(email, password)
        puts "login success"
      end

      desc "project_init", "set a project from flow ci to operation"
      def project_init
        projects = @api_manager.fetch_projects
        begin
          file_origin = `git remote -v`.to_s.match("git.*.git").first
        rescue
          puts @warn.call "read git origin fail..."
        end

        dict = {}
        dict = Hash[projects.map { |p| [p[:name].to_s, p[:id]] }]

        current_project_id = @prompt.select("Choose your project?", dict)

        @db_manager.save_attribute(:current_project_id, current_project_id)

        flows = @api_manager.fetch_flows(current_project_id)

        current_flow_id = if flows.count == 1
                            flows.first[:id]
                          else
                            dict = {}
                            flows.each { |p| dict[(p[:name]).to_s] = p[:id] }
                            @prompt.select("Choose your flow?", dict)
                          end
        @db_manager.save_attribute(:current_flow_id, current_flow_id)
        puts "project_id = #{current_project_id}, flow_id = #{current_flow_id}. saved this info..."
      end

      desc "upload_p12 FILE_PATH [p12 password]", "upload_p12"
      def upload_p12(file_path, password = nil)
        basename = File.basename file_path
        project_init unless @db_manager.read_attribute(:current_flow_id)

        api_p12s = @api_manager.load_p12s(@db_manager.read_attribute(:current_flow_id))
        old_p12 = api_p12s.find { |p12| p12[:name] == basename }
        if old_p12.nil?
          if @prompt.ask? "found a same name file, override?"
            @api_manager.delete_p12(old_p12[:id])
          else
            return puts "canceled.."
          end
        end
        @api_manager.upload_p12(@db_manager.read_attribute(:current_flow_id), file_path, password)
      end

      desc "list_p12s", "list_p12s"
      def list_p12s
        puts @api_manager.load_p12s(@db_manager.read_attribute(:current_flow_id))
      end


      desc "upload_provision", "upload_provision"
      def upload_provision
        basename = File.basename file_path
        project_init unless @db_manager.read_attribute(:current_flow_id)

        api_provisions = @api_manager.load_provisions(@db_manager.read_attribute(:current_flow_id))
        old_provision = api_provisions.find { |provision| provision[:name] == basename }
        if old_provision.nil?
          if @prompt.ask? "found a same name file, override?"
            @api_manager.delete_provision(old_provision[:id])
          else
            return puts "canceled.."
          end
        end
        @api_manager.provision(@db_manager.read_attribute(:current_flow_id), file_path)

      end

      desc "list_provisions", "list provisions"
      def list_provisions
        puts @api_manager.load_provisions(@db_manager.read_attribute(:current_flow_id))
      end
    end
  end
end
