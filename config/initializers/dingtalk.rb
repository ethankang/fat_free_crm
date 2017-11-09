Dingtalk.config do |config|
  config.cropid = Rails.configuration.apis["dingtalk"]["cropid"]
  config.cropsecret = Rails.configuration.apis["dingtalk"]["cropsecret"]
  config.agentid = Rails.configuration.apis["dingtalk"]["agentid"]
end
