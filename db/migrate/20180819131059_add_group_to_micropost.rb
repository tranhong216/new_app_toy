class AddGroupToMicropost < ActiveRecord::Migration[5.1]
  def change
    def change
      add_column :microposts, :social_group_id, :integer
    end
  end
end
