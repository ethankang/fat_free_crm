require 'dingtalk/api_base'
require 'dingtalk/http_client'
require 'dingtalk/access_token'
require 'dingtalk/jsapi_ticket'

module Dingtalk
  class Api < ApiBase
    API_BASE = 'https://oapi.dingtalk.com/'.freeze

    def initialize
      @corpid = Dingtalk.corpid
      @corpsecret = Dingtalk.corpsecret
      @client = HttpClient.new(API_BASE, 20)
      @access_token = Dingtalk::AccessToken.new(@client, @corpid, @corpsecret)
      @jsapi_ticket = JsapiTicket.new(@access_token, @client)
    end

    # 通过CODE换取用户身份
    def getuserinfo(code)
      get 'user/getuserinfo', params: {code: code}
    end

    def get_org_user_count(onlyActive=1)
      get 'user/get_org_user_count', params: {onlyActive: onlyActive}
    end
  end
end
