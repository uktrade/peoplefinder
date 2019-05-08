class RemoveUniquenessKeyOnPeopleEmail < ActiveRecord::Migration[5.1]
  def change
    remove_index :people, name: 'index_people_on_lowercase_email'
  end
end
