module Dingtalk
  class MessageApi < Api
    MSG_API_BASE = 'https://eco.taobao.com/'.freeze

    def initialize
      super
      @client = HttpClient.new(MSG_API_BASE, 20)
    end

    def text_msg(content, *userid_list)
      # FIX: 不清楚参数放在payload不成功，现在参数通过header来传递
      post 'router/rest', '', params: message_hash.merge(
        msgtype: 'text',
        msgcontent: JSON.generate(content: content),
        userid_list: userid_list
      )
    end

    protected

    def with_access_token(params = {}, tries = 2)
      params ||= {}
      yield(params.merge(
        session: @access_token.token
      ))
    rescue AccessTokenExpiredError
      access_token.refresh
      retry unless (tries -= 1).zero?
    end

    private

    def message_hash
      {
        format: 'json',
        agent_id: Dingtalk.agentid,
        method: 'dingtalk.corp.message.corpconversation.asyncsend',
        timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        v: 2.0
      }
    end
  end
end
