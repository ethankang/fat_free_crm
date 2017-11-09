module Dingtalk
  class AccessToken

    def initialize(client, cropid, cropsecret)
      @client = client
      @cropid = cropid
      @cropsecret = cropsecret
    end

    def token
      Rails.cache.read("dingtalk_access_token") || refresh
    end

    def refresh
      data = @client.get('gettoken', params: { corpid: @cropid, cropsecret: @cropsecret })

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
