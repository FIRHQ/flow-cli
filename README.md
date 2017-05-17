# Flow::Cli

## Description

flow ci command tool, including build yaml, run build script locally, run a manual job, show latest jobs, and so on. 

## Installation

### One step Installation

curl -L https://raw.githubusercontent.com/FIRHQ/flow-cli/master/simple-install.sh | bash -s

it would：
- install rvm (which manage ruby version)
- install ruby latest version
- using mirror ruby-china.org for GFW (env MIRROR_CHINA_INSTALL to toggle this function in shell script)
- install gem flow-cli

### Manual Installation 

    I guess you had install rvm ?  

    highly recommand to use 'rvm' to install latest ruby (https://rvm.io/)
    (If u want to uninstall everything about flow-cli, U can `rm -rf ~/.rvm` , to uninstall all about ruby, rvm and gems.)


    When u installed latest ruby using rvm, run this command `gem install flow-cli` to install flow-cli 


    Set mirror to avoid GFW block (IF YOU ARE IN CHINA):
    - When rvm installed, run `echo "ruby_url=https://cache.ruby-china.org/pub/ruby" > ~/.rvm/user/db`   before install ruby, 
    - When ruby installed, run `gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/` 


    $ gem install flow-cli


    ** Summary **
    1. install rvm 
    2. install latest ruby on rvm
    3. run command `gem install flow-cli`

### Install from Source

after installed rvm and ruby 

- `git clone https://github.com/FIRHQ/flow-cli`
- `rake install`

## Usage

```
flow-cli --help # help 
flow-cli remote --help# flow ci operation help.
```

## Example

### Build flow yaml 

```
➜  flowclibasic git:(master) ✗ flow-cli build_yaml_file

export_method?  development
less log? Yes
[17:54:50]: $ xcodebuild -list -project ./flowclibasic.xcodeproj
[17:54:52]: $ xcodebuild -showBuildSettings -scheme flowclibasic -project ./flowclibasic.xcodeproj
---
env:
- FLOW_YAML_FROM=flow-cli
flows:
- name: default_flow_by_cli
  language: objc
  version: Xcode8
  env:
  trigger:
    push:
    - develop
    - master
  steps:
  - name: init
    plugin:
      name: objc_init
  - name: git
    plugin:
      name: git
  - name: install
    plugin:
      name: objc_init
  - name: build
    scripts:
    - fastlane gym build --project ./flowclibasic.xcodeproj --scheme flowclibasic
      --output_name flowclibasic --clean false --export_method development --silent

```

### show build script

```
➜  flowclibasic git:(master) ✗ flow-cli show_build_script
This is the build script in yaml

******************************
fastlane gym build --project ./flowclibasic.xcodeproj --scheme flowclibasic --output_name flowclibasic --clean false --export_method development --silent
******************************
```


### Flow-cli login

```
➜  flow-cli git:(master) ✗ flow-cli remote login
email? jc@fir.im
password? ••••••••
you info saved to ~/.flow_cli_config.yml
login success...
```

### Choose a project 

```
➜  flow-cli git:(master) ✗ flow-cli remote project_init
Choose your project? FIRHQ/flow-cli
project_id = 591a8ff86c112a739a1abefe, flow_id = 591a9003ef2cb037c03c0c94. saved this info...
```

### Fetch latest jobs

```
  flow-cli git:(master) ✗ flow-cli remote fetch_latest_jobs
┌──────┬──────────┬──────┬───────┬──────────────┬─────────────────────────┬─────────────────────────────────────────────────────────────────────────────────────────┐
│number│event_type│branch│status │commit_log    │created_at_str           │url                                                                                      │
├──────┼──────────┼──────┼───────┼──────────────┼─────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────┤
│8     │push      │master│success│update version│2017-05-16 17:38:36 +0800│https://dashboard.flow.ci/projects/xxxxxxxxx/jobs/591ac89c6c112a4dfa1abf3f│
│7     │push      │master│success│fix           │2017-05-16 17:37:36 +0800│https://dashboard.flow.ci/projects/xxxxxxxxx/jobs/591ac860ef2cb07df83c0df8│
│6     │push      │master│success│add readme    │2017-05-16 17:21:10 +0800│https://dashboard.flow.ci/projects/xxxxxxxxx/jobs/591ac4866c112a3f6c1abfd8│
│5     │push      │master│success│fix table show│2017-05-16 17:14:31 +0800│https://dashboard.flow.ci/projects/xxxxxxxxx/jobs/591ac2f76c112a4dfa1abf10│
│4     │push      │master│success│fix           │2017-05-16 17:05:28 +0800│https://dashboard.flow.ci/projects/xxxxxxxxx/jobs/591ac0d8fbd08628bbd81e4f│
│3     │push      │master│success│fix           │2017-05-16 17:02:31 +0800│https://dashboard.flow.ci/projects/xxxxxxxxx/jobs/591ac0276c112a3f6c1abf6e│
│2     │push      │master│failure│refactoring   │2017-05-16 14:38:37 +0800│https://dashboard.flow.ci/projects/xxxxxxxxx/jobs/591a9e6d6c112a04a41abf3a│
│1     │manual    │master│success│              │2017-05-16 13:37:52 +0800│https://dashboard.flow.ci/projects/xxxxxxxxx/jobs/591a90306c112a2b6f1abf5d│
└──────┴──────────┴──────┴───────┴──────────────┴─────────────────────────┴─────────────────────────────────────────────────────────────────────────────────────────┘
```

### run a manual job

```
flow-cli git:(master) ✗ flow-cli remote run_manual_job --branch develop
job started. click ( cmd + click ) url to visit on browser
https://dashboard.flow.ci/projects/xxxxxxxxxx/jobs/xxxxxxx
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/flow-cli. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

