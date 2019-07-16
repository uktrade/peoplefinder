class AddPronounsToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :pronouns, :string
  end
end
