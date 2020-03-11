class AddLineManagerToPeople < ActiveRecord::Migration[6.0]
  def change
    add_column :people, :line_manager_id, :integer
  end
end
