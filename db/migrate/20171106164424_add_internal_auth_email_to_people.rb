class AddInternalAuthEmailToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :internal_auth_key, :string, index: true
  end
end
