class AddMicropost < ActiveRecord::Migration[5.1]
  def change
    create_table :microposts do |t|
      t.string :content
      t.integer :user_id
      t.string :picture
      t.integer :social_group_id

      t.timestamps
    end
  end
end
