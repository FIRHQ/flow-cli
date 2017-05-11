require 'oj'
require 'json'
require 'rest-client'

module Flow::Cli
  module Utils
    class LocalServiceRest
      class Error < StandardError; end
      class JSONParseError < Error; end
      class << self
        %w[get delete head].each do |word|
          define_method word.to_sym do |url, params = {}, timeout = 5, retry_times = 5|
            params.merge!(add_those_to_params) # 将默认参数添加到params 里
            url = basic_url + url
            exception = nil
            retry_times.times do
              begin
                headers = json_content_type
                headers[:params] = if headers[:params]
                                     headers[:params].merge(params)
                                   else
                                     params
                                   end
                response = ::RestClient::Request.execute(
                  method:  word,
                  url:     url,
                  headers: headers,
                  timeout: timeout
                )
                return ::Oj.load(response.body, symbol_keys: true)
              rescue ::Oj::Error
                raise ::LocalServiceRest::JSONParseError('返回的内容JSON解析失败')
              rescue ::RestClient::ExceptionWithResponse => ex # 有返回的错误
                raise ex unless ex.http_code.to_i < 500 && ex.http_code.to_i >= 300 # 这里主要是服务器返回了500 了，没必要解析body
                return { # 这里是服务器有返回的错误，都应该是json 格式的
                  status: false,
                  json: ::Oj.load(ex.response.body, symbol_keys: true),
                  response_body: ex.response.body,
                  message: ex.message
                }
              rescue RestClient::Exception => e
                exception = e
                next
              end
            end
            raise exception
          end
        end

        %w[post patch put].each do |word|
          define_method word.to_sym do |url, payload, timeout = 5, retry_times = 5|
            payload = add_something_to_payload(payload)
            url = build_valid_url(url)
            exception = nil
            retry_times.times do
              begin
                request = ::RestClient::Request.execute(
                  method:  word,
                  url:     url,
                  payload: payload.to_json,
                  headers: json_content_type,
                  timeout: timeout
                )
                return ::Oj.load(request.body, symbol_keys: true)
              rescue ::Oj::Error
                raise ::LocalServiceRest::JSONParseError('返回的内容JSON解析失败')
              rescue ::RestClient::ExceptionWithResponse => ex # 有返回的错误
                raise ex unless ex.http_code < 500 && ex.http_code >= 300
                return {
                  status: false,
                  json: ::Oj.load(ex.response.body, symbol_keys: true),
                  response_body: ex.response.body,
                  message: ex.message
                }
              rescue RestClient::Exception => e
                exception = e
                next
              end
            end
            raise exception
          end
        end

        def build_valid_url(url)
          add_params = URI.escape(add_those_to_params.collect { |k, v| "#{k}=#{v}" }.join('&'))
          tmp = url.include?('?') ? '&' : '?'
          basic_url + url + tmp + add_params
        end

        def add_something_to_payload(payload)
          payload.merge(add_those_to_params)
        end

        def json_content_type
          { content_type: :json, accept: :json }
        end

        def basic_url
          'http://www.example.com' # 子类中复写
        end

        def add_those_to_params
          {} # 子类中复写
        end
      end
    end
  end
end
