require "bundler/setup"

require 'simplecov'
SimpleCov.start do
  add_filter "/vendors/"
end

require "flow/cli"
require "byebug"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
