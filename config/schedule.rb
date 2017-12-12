# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :environment, :development
# 如果有新创建的线索，每隔5分钟提醒客服人员分配线索
# 如果销售人员有新的线索没有处理，每隔10分钟提醒进行线索处理
every 5.minutes do
  runner "Lead.customer_server_remind"
  runner "Lead.sales_remind"
end
