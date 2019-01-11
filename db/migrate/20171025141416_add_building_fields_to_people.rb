class AddBuildingFieldsToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :other_uk, :text
    add_column :people, :other_overseas, :text
  end
end
