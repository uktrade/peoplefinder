class RemovePhoneNumberCountryCodesFromPeople < ActiveRecord::Migration[6.0]
  def change
    remove_column :people, :primary_phone_country_code
    remove_column :people, :secondary_phone_country_code
  end
end
