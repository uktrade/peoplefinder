class AddMoreEmailsToPeople < ActiveRecord::Migration[6.0]
  def change
    add_column :people, :contact_email, :string
  end
end
