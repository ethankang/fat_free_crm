namespace :leads do
  task :change_owner,[:from_user_id,:to_user_id] => :environment do  |t, args|
    user = User.find_by_id(args.from_user_id)
    leads_from_user = Lead.create_or_assigned(user)
    Lead.change_leads_owner(leads_from_user,args.to_user_id)
  end
end