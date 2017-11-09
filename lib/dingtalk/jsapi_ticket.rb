module Dingtalk
  class JsapiTicket

    def initialize(access_token, client)
      @access_token = access_token
      @client = client
    end

    def ticket
      Rails.cache.read("dingtalk_jsapi_ticket") || refresh
    end

    def signature(url)
      params = {
        jsapi_ticket: ticket,
        noncestr: SecureRandom.base64(16),
        timestamp: Time.now.to_i,
        url: url
      }
      pairs = params.keys.sort.map do |key|
        "#{key}=#{params[key]}"
      end
      result = Digest::SHA1.hexdigest pairs.join('&')
      params.merge(signature: result)
    end

    def refresh
      data = @client.get('get_jsapi_ticket', params: { access_token: @access_token.token, type: 'jsapi' })

      if !data["ticket"].blank?
        Rails.cache.write(
          "dingtalk_jsapi_ticket",
          data["ticket"],
          expires_in: (2.hours - Dingtalk::EXPIRE_OFFSET)
        )
      end
      data["dingtalk_jsapi_ticket"]
    end
  end
end
