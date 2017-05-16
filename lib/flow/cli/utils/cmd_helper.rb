require 'forwardable'

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
        puts log
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
    end
  end
end
