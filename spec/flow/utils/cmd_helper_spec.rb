require "spec_helper"
module Flow::Cli
  module Utils
    RSpec.describe CmdHelper do
      it 'could puts commands' do
        expect(DbManager.read.class).to eq Hash
      end
    end
  end
end
