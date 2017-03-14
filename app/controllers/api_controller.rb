# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class ApiController < ActionController::Base
  def create_lead

    lead = Lead.find_by_phone(params[:phone])
    user_id = 2 # 即客服
    if lead
      lead.comments.create(
        comment: "重复提交：#{params[:name]}-#{params[:phone]}-#{params[:company]}",
        user_id: user_id
      )
    else
      Lead.create(
        user_id: user_id,
        status: :new,
        access: "Private",
        source: :web,
        first_name: params[:name],
        company: params[:company],
        phone: params[:phone],
        business_address_attributes: {
          address_type: "Business",
          state: params[:state],
          city: params[:city]
        }
      )
    end
    render nothing: true
  end
end
