class AddConvertedAtToLeads < ActiveRecord::Migration
  def change
    add_column :leads,:converted_at,:datetime
    add_column :leads,:converted_operate_id,:integer
  end
end
