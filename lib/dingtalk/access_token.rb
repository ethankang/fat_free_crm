module Dingtalk
  class AccessToken

    def initialize(client, corpid, corpsecret)
      @client = client
      @corpid = corpid
      @corpsecret = corpsecret
    end

    def token
      Rails.cache.read("dingtalk_access_token") || refresh
    end

    def refresh
      data = @client.get('gettoken', params: { corpid: @corpid, corpsecret: @corpsecret })

      if !data["access_token"].blank?
        Rails.cache.write(
          "dingtalk_access_token",
          data["access_token"],
          expires_in: (2.hours - Dingtalk::EXPIRE_OFFSET)
        )
      end
      data["dingtalk_access_token"]
    end

  end
end
