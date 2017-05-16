# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flow/cli/version'

Gem::Specification.new do |spec|
  spec.name          = "flow-cli"
  spec.version       = Flow::Cli::VERSION
  spec.authors       = ["atpking"]
  spec.email         = ["atpking@gmail.com"]

  spec.summary       = "Flow CI CLI"
  spec.description   = "Flow CI CLI, used to build yaml, run ci yaml locally."
  spec.homepage      = "https://flow.ci"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.post_install_message = %q(
  _____ _     _____        ______ ___    ____ _     ___
 |  ___| |   / _ \ \      / / ___|_ _|  / ___| |   |_ _|
 | |_  | |  | | | \ \ /\ / / |    | |  | |   | |    | |
 |  _| | |__| |_| |\ V  V /| |___ | |  | |___| |___ | |
 |_|   |_____\___/  \_/\_/(_)____|___|  \____|_____|___|

 ****************************************************
 这是 flow.ci CLI 的早期版本，暂时只支持 ios 项目

0.0.5 版本增加 增加了一些 remote 指令，包括最近jobs，手动构建一次job
0.0.4 版本修正 在执行一些remote 指令，如果没登录，会报错的问题 另附增加 remote reset 指令
0.0.3 版本新增 flow-cli remote 系列指令，支持传证书，传provisions 文件

  )

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "byebug"

  spec.add_dependency "thor", "~> 0.18"
  spec.add_dependency "tty", "~> 0.7"
  spec.add_dependency "fastlane", "~> 2.28"
  spec.add_dependency "oj", "~> 2"
  spec.add_dependency "rest-client"
end
