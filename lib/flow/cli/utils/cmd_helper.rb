require 'forwardable'
require 'byebug'

module Flow::Cli
  module Utils
    class CmdHelper
      extend Forwardable
      attr_accessor :prompt
      def initialize
        @pastel = Pastel.new
        self.prompt = TTY::Prompt.new
      end

      def_delegators :prompt, :ask, :yes?, :mask, :select

      def echo(log)
        @green ||= @pastel.green.bold.detach
        puts @green.call log
      end

      def puts_table(arr_dict, sorted_titles = nil)
        sorted_titles = arr_dictt.first.keys if sorted_titles.nil?
        table = TTY::Table.new header: sorted_titles
        arr_dict.each do |item| 
          show_item = []
          sorted_titles.each do |key|
            show_item << item[key]
          end
          table << show_item
        end
        puts table.render(:unicode)
      end

      def puts_error(log)
        @error ||= @pastel.red.bold.detach
        puts @error.call(log)
      end

      def puts_warning(log)
        @warning ||= @pastel.yellow.detach
        puts @warning.call(log)
      end

      alias error puts_error
      alias warning puts_warning
      alias warn puts_warning

      class << self
        def instance
          new
        end
      end
    end
  end
end
