# frozen_string_literal: true

module SpecSupport
  module Profile
    def person_attributes
      {
        given_name: 'Marco',
        surname: 'Polo',
        email: 'marco.polo@digital.justice.gov.uk',
        primary_phone_number: '0208-123-4567',
        secondary_phone_number: '718-555-1212',
        location_in_building: '10.999',
        city: 'London',
        country: 'United Kingdom'
      }
    end

    def complete_profile!(person)
      profile_photo = create(:profile_photo)
      line_manager = create(:person)
      person.update(
        person_attributes
          .except(:email)
          .merge(profile_photo_id: profile_photo.id, line_manager_id: line_manager.id, country: 'GB')
      )
      person.groups << create(:group)
    end

    def click_edit_profile(matcher = :first)
      click_link('Edit profile', match: matcher)
    end

    def click_delete_profile(matcher = :first)
      click_link('Delete profile', match: matcher)
    end
  end
end
