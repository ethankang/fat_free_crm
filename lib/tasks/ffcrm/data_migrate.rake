namespace :ffcrm do
  namespace :data_migrate do
    desc "批量把某个销售的所有客户转移给另一个销售"
    task :change_user_all_accounts_to, [:old_user_id, :new_user_id] => :environment do |t, args|
      old_user, new_user = User.where(id: [args[:old_user_id].to_i, args[:new_user_id].to_i])
      p "把#{old_user.name}的客户分配给#{new_user.name} "

      Account.assigned_to(old_user).find_each do |account|
        p " 更新 account: #{account.id}-#{account.name}"
        if account.update(assigned_to: new_user.id)
          p " 成功"
        else
          p " 失败原因：#{account.errors.full_messages}"
        end
      end
      p "完成!"
    end

    desc "把某个销售，线索下的备注转移至account客户下"
    task :move_comments_from_lead_to_account do
      user = User.find 20
      Lead.where(assigned_to: user.id, status: "converted").each do |l|
        a = l.contact.account
        l.comments.where(user_id: user.id).each {|c| c.update commentable: a}
      end
    end
  end
end
