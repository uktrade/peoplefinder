class AddLastEditedOrConfirmedToPerson < ActiveRecord::Migration[6.0]
  def up
    add_column :people, :last_edited_or_confirmed_at, :datetime
    execute 'UPDATE people SET last_edited_or_confirmed_at = updated_at'
  end

  def down
    remove_column :people, :last_edited_or_confirmed_at
  end
end
