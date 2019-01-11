class AddPrimaryPhoneCountryCodeToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :primary_phone_country_code, :text
  end
end
