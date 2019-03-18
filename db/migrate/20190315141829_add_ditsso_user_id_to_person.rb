class AddDitssoUserIdToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :ditsso_user_id, :string
  end
end
