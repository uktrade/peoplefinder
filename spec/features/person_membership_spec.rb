# frozen_string_literal: true

require 'rails_helper'

describe 'Person membership' do
  before do
    omni_auth_log_in_as '007'
  end

  before(:each, user: :groups_editor) do
    omni_auth_log_in_as_groups_editor
  end

  it 'Editing a job title', js: true do
    person = create_person_in_digital_justice

    visit edit_person_path(person)
    fill_in 'Job title', match: :first, with: 'Head Honcho'
    click_button 'Save', match: :first

    expect(page).to have_selector('.ws-profile__role', text: 'Head Honcho in Digital Justice', normalize_ws: true)
  end

  it 'Leaving the job title blank', js: true do
    person = create_person_in_digital_justice

    visit edit_person_path(person)
    fill_in 'Job title', with: ''
    click_button 'Save', match: :first

    expect(page).to have_selector('.ws-profile__role', text: 'Member of Digital Justice', normalize_ws: true)
  end

  it 'Changing team membership via clicking "Back"', js: true do
    department = create(:department, name: 'Ministry of Justice')
    parent_group = create(:group, name: 'CSG', parent: department)
    create(:group, name: 'Technology', parent: parent_group)
    group = create(:group, name: 'Digital Services', parent: parent_group)

    person = create(:person, :member_of, team: group, sole_membership: true)

    visit edit_person_path(person)

    within('.ws-profile-edit__team') do
      click_button 'Change team'
      click_button 'Back'
      choose 'CSG'
    end

    click_button 'Save', match: :first

    person.reload
    expect(person.memberships.last.group).to eql(Group.find_by(name: 'CSG'))
  end

  it 'Joining another team with a role', js: true do
    person = create_person_in_digital_justice
    create(:group, name: 'Communications', parent: Group.department)

    visit edit_person_path(person)

    click_button('Add another team')

    within('.ws-profile-edit__team:last-of-type') do
      choose 'Communications'
      fill_in 'Job title', with: 'Talker'
    end

    click_button 'Save', match: :first
    expect(Person.last.memberships.length).to be(2)
  end

  it 'Adding a permanent secretary', js: true do
    person = create_person_in_digital_justice
    visit edit_person_path(person)
    fill_in 'First name', with: 'Samantha'
    fill_in 'Last name', with: 'Taylor'
    fill_in 'Job title', with: 'Permanent Secretary'

    check "#{person.given_name} is the head of this team", allow_label_click: true
    click_button 'Change team'
    click_button 'Back to Ministry of Justice'
    choose 'Ministry of Justice'
    click_button 'Save', match: :first

    visit group_path(Group.find_by(name: 'Ministry of Justice'))
    within('.ws-person-cards--leaders') do
      expect(page).to have_link('Samantha Taylor')
      expect(page).to have_text('Permanent Secretary')
    end

    visit person_path(person)
    expect(page).to have_selector('.ws-profile__role', text: 'Permanent Secretary', normalize_ws: true)
  end

  it 'Adding an additional leadership role in same team', js: true do
    person = create_person_in_digital_justice
    visit edit_person_path(person)

    fill_in 'First name', with: 'Samantha'
    fill_in 'Last name', with: 'Taylor'
    fill_in 'Job title', with: 'Head Honcho'
    check "#{person.given_name} is the head of this team", allow_label_click: true

    click_button('Add another team')

    within('.ws-profile-edit__team:last-of-type') do
      choose 'Digital Justice'
      fill_in 'Job title', with: 'Master of None'
      check "#{person.given_name} is the head of this team", allow_label_click: true
    end

    click_button 'Save', match: :first

    visit group_path(Group.find_by(name: 'Digital Justice'))
    within('.ws-person-cards--leaders') do
      expect(page).to have_link('Samantha Taylor')
      expect(page).to have_text('Head Honcho, Master of None')
    end

    visit person_path(person)
    expect(page).to have_selector('.ws-profile__role', text: 'Head Honcho in Digital Justice', normalize_ws: true)
    expect(page).to have_selector('.ws-profile__role', text: 'Master of None in Digital Justice', normalize_ws: true)
  end

  it 'Leaving a team', js: true do
    ds = create(:group, name: 'Digital Justice')
    person = create(:person, :member_of, team: ds, role: 'tester', sole_membership: false)
    expect(person.memberships.count).to be 2

    visit edit_person_path(person)
    within('.ws-profile-edit__team:last-of-type') do
      click_button 'Leave this team'
    end
    click_button 'Save'

    expect(page).to have_current_path(person_path(person))
    expect(page).to have_content('Thank you for helping to improve People Finder')
    expect(person.reload.memberships.count).to be 1
  end
end

def create_person_in_digital_justice
  department = create(:department, name: 'Ministry of Justice')
  group = create(:group, name: 'Digital Justice', parent: department)

  create(:person, :member_of, team: group, sole_membership: true)
end
