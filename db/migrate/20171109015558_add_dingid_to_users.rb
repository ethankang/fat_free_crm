class AddDingidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dingid, :string
    add_index :users, :dingid
  end
end
