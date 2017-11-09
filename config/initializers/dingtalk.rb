Dingtalk.config do |config|
  config.corpid = Rails.configuration.apis["dingtalk"]["corpid"]
  config.corpsecret = Rails.configuration.apis["dingtalk"]["corpsecret"]
  config.agentid = Rails.configuration.apis["dingtalk"]["agentid"]
end
