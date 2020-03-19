class AddLineManagerNotRequiredToPeople < ActiveRecord::Migration[6.0]
  def change
    add_column :people, :line_manager_not_required, :boolean, default: false
  end
end
