require 'yaml'
require 'byebug'
require "pastel"
require "tty-table"
require "tty-prompt"
require "tty-command"
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

      desc "help_ios_init", 'how to fetch provisions, p12 files'
      def help_ios_init
        @cmd_helper.echo_warning %(when you build ios project, you should upload p12 and provision to flow ci project

          followed this website to build p12 and provision files

          http://docs.flow.ci/en/upload_certificate_and_provisioning_profiles.html    (EN)
          http://docs.flow.ci/zh/upload_certificate_and_provisioning_profiles.htm     (ZH)

          when you exported p12s and provisons correctly,
          run `flow-cli remote upload_p12 FILE` and `flow-cli remote upload_provision FILE` to upload the files.
        )
      end

      desc "login", "bind flow ci account to flow cli."
      def login
        email = @cmd_helper.ask("email?")
        password = @cmd_helper.mask("password?")
        Utils::FlowApiManager.login(email, password)
        @cmd_helper.echo_warning "you info saved to ~/.flow_cli_config.yml"
        @cmd_helper.echo "login success..."
      end

      option :branch, default: "master"
      desc "run_manual_job", 'run manual job(default branch master) using --branch to specify branch'
      def run_manual_job
        choosed_project_check
        answer = @api_manager.run_manual_job(
          current_flow_id,
          current_project_id,
          options[:branch]
        )
        @cmd_helper.echo("job started. click ( cmd + click ) url to visit on browser")
        @cmd_helper.echo("https://dashboard.flow.ci/projects/#{current_project_id}/jobs/#{answer[:id]}")
      end
      desc "reset", "reset flow api info data"
      def reset
        @db_manager.reset
        @cmd_helper.echo_warning "reset ok"
      end

      desc "project_init", "set a project from flow ci to operation"
      def project_init
        projects = current_api_manager.fetch_projects
        # begin
        #   file_origin = `git remote -v`.to_s.match("git.*.git").first
        # rescue
        #   cmd_helper.echo_warning "read git origin fail..."
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
            return @cmd_helper.echo_warning "canceled..."
          end
        end
        current_api_manager.upload_p12(@db_manager.read_attribute(:current_flow_id), file_path, password)
        puts "uploaded. you can run `flow-cli remote list_p12s` to check the operation."
      end

      desc "list_p12s", "list_p12s"
      def list_p12s
        choosed_project_check
        dict = current_api_manager.load_p12s(current_flow_id)
        if dict.count.zero?
          @cmd_helper.echo_warning("no p12 found in project #{current_project_id}")
        else
          @cmd_helper.puts_table(dict)
        end
      end

      desc "fetch_latest_jobs", "fetch_latest_jobs"
      def fetch_latest_jobs
        choosed_project_check
        list = @api_manager.fetch_latest_jobs(current_flow_id, current_project_id)
        show_data = list.map do |item|
          tmp = item.slice(:id, :status, :event_type, :number, :branch, :commit_log)
          tmp[:created_at_str] = Time.at(item[:created_at]).to_s
          tmp[:url] = "https://dashboard.flow.ci/projects/#{current_project_id}/jobs/#{tmp[:id]}"
          tmp
        end
        @cmd_helper.puts_table(show_data, %i[number event_type branch status commit_log created_at_str url])
      end

      desc "upload_provision FILE_PATH", "upload_provision"
      def upload_provision(file_path)
        choosed_project_check
        basename = File.basename file_path

        api_provisions = current_api_manager.load_provisions(current_flow_id)
        old_provision = api_provisions.find { |provision| provision[:filename] == basename }
        unless old_provision.nil?
          if @cmd_helper.yes? "found a same name file, override?"
            current_api_manager.delete_provision(old_provision[:id], current_flow_id)
          else
            return puts "canceled.."
          end
        end
        current_api_manager.upload_provision(current_flow_id, file_path)
        puts "uploaded. you can run `flow-cli remote list_provisions` to check the operation."
      end

      desc "list_provisions", "list provisions"
      def list_provisions
        choosed_project_check
        dict =  current_api_manager.load_provisions(current_flow_id)
        if dict.count.zero?
          @cmd_helper.echo_warning("no p12 found in project #{current_project_id}")
        else
          @cmd_helper.puts_table(dict)
        end
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

        def current_project_id
          @current_project_id ||= @db_manager.read_attribute(:current_project_id)
        end

        def current_flow_id
          @current_flow_id ||= @db_manager.read_attribute(:current_flow_id)
        end

        def choosed_project_check
          project_init if @db_manager.read_attribute(:current_project_id).nil?
        end
      end
    end
  end
end
