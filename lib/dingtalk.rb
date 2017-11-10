require 'dingtalk/api'
require 'dingtalk/helpers'

module Dingtalk
  # token 提前过期偏移量
  EXPIRE_OFFSET = 5.minutes

  # configurations
  mattr_accessor :corpid, :corpsecret, :agentid

  class AccessTokenExpiredError < StandardError; end
  class ResponseError < StandardError
    attr_reader :error_code
    def initialize(errcode, errmsg)
      @error_code = errcode
      super "#{errmsg}(#{error_code})"
    end
  end

  def self.config
    yield(self)
  end

  def self.api
    @api ||= Api.new
  end

  def self.message_api
    @message ||= MessageApi.new
  end
end

ActionView::Base.send :include, Dingtalk::Helpers if defined? ActionView::Base

# 开发模式下，autoload 时，同步load initializer 配置
load Rails.root.join('config/initializers/dingtalk.rb') if Rails.env.development?
