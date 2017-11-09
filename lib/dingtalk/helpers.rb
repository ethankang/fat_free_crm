module Dingtalk
  module Helpers
    def dingtalk_config_js(config_options = {})
      page_url = controller.request.original_url
      js_hash = Dingtalk.api.jsapi_ticket.signature(page_url)
      config_js = <<-DINGTALK_CONFIG_JS
dd.config({
  agentId: "#{Dingtalk.agentid}",
  corpId: "#{Dingtalk.cropid}",
  timeStamp: "#{js_hash[:timestamp]}",
  nonceStr: "#{js_hash[:noncestr]}",
  signature: "#{js_hash[:signature]}",
  jsApiList: ['#{config_options[:api].join("','")}']
});
DINGTALK_CONFIG_JS

      javascript_tag config_js, type: 'application/javascript'
    end
  end
end
