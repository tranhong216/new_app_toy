class CreateGroupUser < ActiveRecord::Migration[5.1]
  def change
    create_table :group_users do |t|
      t.integer :user_id
      t.integer :social_group_id

      t.timestamps
    end
  end
end
