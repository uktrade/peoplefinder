class AddContactInfoToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :country, :string
    add_column :people, :skype_name, :string
  end
end
