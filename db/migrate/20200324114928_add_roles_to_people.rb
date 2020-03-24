class AddRolesToPeople < ActiveRecord::Migration[6.0]
  def change
    rename_column :people, :super_admin, :role_administrator
    add_column :people, :role_people_editor, :boolean, default: false
    add_column :people, :role_groups_editor, :boolean, default: false
  end
end
