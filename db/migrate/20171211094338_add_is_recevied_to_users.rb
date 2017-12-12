class AddIsReceviedToUsers < ActiveRecord::Migration
  def change
    add_column :users,:is_received,:boolean,:default => true
  end
end
