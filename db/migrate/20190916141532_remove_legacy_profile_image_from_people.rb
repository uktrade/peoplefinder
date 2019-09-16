class RemoveLegacyProfileImageFromPeople < ActiveRecord::Migration[5.1]
  def change
    remove_column :people, :image
  end
end