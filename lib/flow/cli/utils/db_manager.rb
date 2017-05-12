require 'yaml'

module Flow::Cli
  module Utils
    class DbManager
      class << self
        FLOW_CLI_CONFIG = "#{ENV['HOME']}/.flow_cli_config.yml".freeze

        def overide_save(hash)
          File.open(FLOW_CLI_CONFIG, "w") do |file|
            file << hash.to_yaml
          end
          hash
        end

        def save(settings)
          old = read
          settings = old.merge(settings).compact
          yaml = settings.to_yaml
          File.open(FLOW_CLI_CONFIG, "w") do |file|
            file << yaml
          end
          settings
        end

        def save_attribute(key, val)
          dict = read
          dict[key.to_s] = val
          save(dict)
        end

        def read
          return {} unless File.file?(FLOW_CLI_CONFIG)
          config = YAML.safe_load(File.open(FLOW_CLI_CONFIG))
          raise "yaml load is not a hash #{config.class}" unless config.is_a? Hash
          config
        end

        def read_attribute(key)
          read[key.to_s]
        end
      end
    end
  end
end
