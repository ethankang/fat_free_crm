# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
namespace :ffcrm do
  namespace :leads do
    desc "Run comment inbox crawler and process incoming emails"
    task create: :environment do
      l = Lead.create! user_id: 2,
        status: :new,
        access: "Private",
        source: :web,
        first_name: ENV["NAME"],
        company: ENV["COMPANY"],
        phone: ENV["PHONE"],
        business_address_attributes: {
          address_type: "Business",
#           full_address: ENV["ADDR"],
          state: ENV["STATE"],
          city: ENV["CITY"],
        }
      pp l
      pp l.business_address
    end
  end
end
