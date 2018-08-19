class UpdateUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :admin, :boolean
    add_column :users, :activation_digest, :string
    add_column :users, :activated, :boolean
    add_column :users, :activated_at, :datetime
    remove_column :users, :name
    remove_column :users, :date_of_birth
  end
end
