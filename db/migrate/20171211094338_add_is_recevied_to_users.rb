class AddIsReceviedToUsers < ActiveRecord::Migration
  def change
    add_column :users,:ding_enabled,:boolean,:default => true
  end
end
