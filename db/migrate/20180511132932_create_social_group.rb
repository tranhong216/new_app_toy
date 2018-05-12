class CreateSocialGroup < ActiveRecord::Migration[5.1]
  def change
    create_table :social_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
