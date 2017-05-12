require "spec_helper"
module Flow::Cli
  module Utils
    RSpec.describe DbManager do
      it 'could return hash' do
        expect(DbManager.read.class).to eq Hash
      end

      it 'could save data' do
        DbManager.save("my_test_key" => 1)
        expect(DbManager.read["my_test_key"]).to eq 1
      end

      it 'could save attribute' do
        DbManager.save_attribute('my_test_key', 2)
        expect(DbManager.read["my_test_key"]).to eq 2
      end

      it "could read attribute" do
        DbManager.save_attribute('my_test_key', 3)
        expect(DbManager.read_attribute("my_test_key")).to eq 3
      end

      it 'could set attribute to nil' do
        DbManager.save_attribute('my_test_key', nil)
        expect(DbManager.read_attribute("my_test_key")).to eq nil
        expect(DbManager.read.keys.include?("my_test_key")).to eq false
      end
    end
  end
end
