class AddSecondaryPhoneCountryCodeToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :secondary_phone_country_code, :text
  end
end
