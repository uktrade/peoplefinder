class RemoveLegacyPeopleFields < ActiveRecord::Migration[6.0]
  def change
    remove_column :people, :internal_auth_key, :string
    remove_column :people, :pager_number, :text
    remove_column :people, :description, :text
    remove_column :people, :current_project, :string
    remove_column :people, :secondary_email, :text
  end
end
