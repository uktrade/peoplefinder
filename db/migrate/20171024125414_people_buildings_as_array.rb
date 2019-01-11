class PeopleBuildingsAsArray < ActiveRecord::Migration[4.2]
  def change
    remove_column :people, :building, :text
    add_column :people, :building, :string, array: true, default: []
  end
end
