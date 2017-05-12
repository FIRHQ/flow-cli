require_relative './local_service_rest'
module Flow::Cli
  module Utils
    class FlowApiRest < LocalServiceRest
      class << self
        def basic_url
          FLOW_API_URL # 子类中复写
        end

        %i[get delete head post patch put].each do |method|
          alias_method "#{method}_old", method
          define_method method do |*args, &blk|
            ret = __send__ "#{method}_old", *args, &blk
            raise "response_body = #{ret[:response_body]}" if ret[:status] == false
          end
        end
      end
    end
  end
end
