set :output, File.expand_path("../../log/whenever.log", __FILE__)

# 客服人员有未分配的新线索，每5分钟通知销售经理进行分配
# 销售人员有新的线索没有处理，通知销售人员进行处理
every '0,5 9-18 * * *' do
  runner "Lead.ding_sales_manager"
  runner "Lead.ding_sales"
end
