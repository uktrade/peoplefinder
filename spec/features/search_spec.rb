# frozen_string_literal: true

require 'rails_helper'

describe 'Searching feature', elasticsearch: true do
  before do
    group = create(:group, name: 'My Fancy Group')
    create(
      :person,
      :member_of,
      team: group,
      sole_membership: true,
      given_name: 'Jon',
      surname: 'Browne',
      email: 'jon.browne@digital.trade.gov.uk',
      primary_phone_number: '0711111111',
      language_fluent: 'Spanish, Italian',
      key_skills: ['interviewing']
    )
    create(
      :person,
      given_name: 'Dodgy<script> alert(\'XSS\'); </script>',
      surname: 'Person',
      email: 'dodgy.person@digital.trade.gov.uk',
      primary_phone_number: '0711111111'
    )

    Person.__elasticsearch__.refresh_index!

    omni_auth_log_in_as '007'
    visit home_path
  end

  describe 'for a blank search' do
    it 'returns no results' do
      click_button 'Search'
      expect(page).to have_content('No search results')
    end
  end

  describe 'for people' do
    it 'retrieves the details of matching people' do
      fill_in 'Search people, teams and skills', with: 'Browne'
      click_button 'Search'

      expect(page).to have_selector('.ws-person-search-result', count: 1, text: /Jon Browne/)
    end
  end

  describe 'for groups' do
    it 'retrieves the details of the matching group and people in that group' do
      fill_in 'Search people, teams and skills', with: 'my fancy group'
      click_button 'Search'

      expect(page).to have_selector('.ws-group-cards__item', count: 1, text: /My Fancy Group/)
      expect(page).to have_selector('.ws-person-search-result', count: 1, text: /Jon Browne/)
    end
  end
end
