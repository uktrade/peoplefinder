# frozen_string_literal: true

require 'rails_helper'

describe 'Audit trail' do
  before do
    omni_auth_log_in_as_administrator
  end

  it 'Auditing an edit of a person' do
    with_versioning do
      person = create(:person, surname: 'original surname')
      visit edit_person_path(person)
      fill_in 'Last name', with: 'something else'
      click_button 'Save', match: :first

      visit '/audit_trail'
      expect(page).to have_text('Person Edited')
      expect(page).to have_text('Surname set to something else (was original surname)')

      click_button 'Undo change', match: :first

      person.reload
      expect(person.surname).to eq('original surname')
    end
  end

  it 'Auditing the deletion of a person' do
    with_versioning do
      person = create(:person, surname: 'Dan', given_name: 'Greg')
      visit person_path(person)
      click_delete_profile

      visit '/audit_trail'
      expect(page).to have_text('Deleted Person')
      expect(page).to have_text('Name: Greg Dan')

      expect do
        click_button 'Undo change', match: :first
      end.to change(Person, :count).by(1)
    end
  end

  it 'Auditing an edit of a group' do
    with_versioning do
      group = create(:group, name: 'original name')
      visit edit_group_path(group)
      fill_in 'Team name', with: 'something else'
      click_button 'Save', match: :first

      visit '/audit_trail'
      expect(page).to have_text('Group Edited')
      expect(page).to have_text('Name set to something else (was original name)')
    end
  end

  it 'Auditing the creation of a group' do
    with_versioning do
      visit new_group_group_path(Group.department.slug)
      fill_in 'Team name', with: 'Jon'
      click_button 'Save', match: :first

      visit '/audit_trail'
      expect(page).to have_text('New Group')
      expect(page).to have_text('Name set to Jon')
    end
  end

  it 'Auditing the deletion of a group' do
    with_versioning do
      group = create(:group, name: 'original name')
      visit edit_group_path(group)
      click_link('Delete this team')

      visit '/audit_trail'
      expect(page).to have_text('Deleted Group')
      expect(page).to have_text('Name: original name')
    end
  end

  it 'Auditing the creation of a membership', js: true do
    group = create(:group, name: 'Digital')
    person = create(:person, given_name: 'Bob', surname: 'Smith')
    person.memberships.destroy_all

    with_versioning do
      visit edit_person_path(person)

      within '.ws-profile-edit__team:last-of-type' do
        choose 'Digital'
        fill_in 'Job title', with: 'Jefe'
      end
      click_button 'Save'
    end

    visit '/audit_trail'
    within('tbody tr:first-child') do
      expect(page).to have_text('New Membership')
      expect(page).to have_text("Person set to #{person.id}")
      expect(page).to have_text("Group set to #{group.id}")
      expect(page).to have_text('Role set to Jefe')
      expect(page).not_to have_button 'Undo change'
    end
  end

  it 'Auditing the deletion of a membership', js: true do
    group1 = create(:group, name: 'Test Group 1')
    group2 = create(:group, name: 'Test Group 2')
    person = create(:person)
    person.memberships.create!(
      [
        { group: group1, leader: false, role: 'Individual' },
        { group: group2, leader: true, role: 'Jefe' }
      ]
    )

    with_versioning do
      visit edit_person_path(person)
      within '.ws-profile-edit__team:last-of-type' do
        click_button 'Leave this team'
      end
      click_button 'Save'
    end

    visit '/audit_trail'

    expect(page).to have_text('Deleted Membership')
    expect(page).to have_text('Group removed')
    expect(page).to have_text('Role removed (was Jefe)')
    expect(page).to have_text('Leader removed (was true)')
  end
end
