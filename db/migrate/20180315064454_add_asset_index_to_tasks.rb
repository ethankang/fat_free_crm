class AddAssetIndexToTasks < ActiveRecord::Migration
  def change
    add_index :tasks, [:asset_id, :asset_type]
  end
end
