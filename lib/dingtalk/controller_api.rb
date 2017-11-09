module Dingtalk
  module ControllerApi
    extend ActiveSupport::Concern

    module ClassMethods
      attr_accessor :dingtalk_api_client, :token, :corpid, :agentid, :timeout, :trusted_domain_fullname
    end

    def dingtalk
      self.class.dingtalk
    end

  end
end
