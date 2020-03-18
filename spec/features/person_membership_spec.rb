# frozen_string_literal: true

require 'rails_helper'

describe 'Person membership' do
  before do
    omni_auth_log_in_as '007'
  end

  before(:each, user: :groups_editor) do
    omni_auth_log_in_as_groups_editor
  end

  let(:edit_profile_page) { Pages::EditProfile.new }

  it 'Editing a job title', js: true do
    person = create_person_in_digital_justice

    visit edit_person_path(person)
    expect(page).to have_selector('.team-led', text: 'Digital Justice team')

    fill_in 'Job title', match: :first, with: 'Head Honcho'
    click_button 'Save', match: :first

    expect(page).to have_selector('.ws-profile__role', text: 'Head Honcho in Digital Justice', normalize_ws: true)
  end

  it 'Leaving the job title blank', js: true do
    person = create_person_in_digital_justice

    visit edit_person_path(person)
    expect(page).to have_selector('.team-led', text: 'Digital Justice team')

    fill_in 'Job title', with: ''

    click_button 'Save', match: :first

    expect(page).to have_selector('.ws-profile__role', text: 'Member of Digital Justice', normalize_ws: true)
  end

  it 'Changing team membership via clicking "Back"', js: true do
    group = setup_three_level_team
    person = setup_team_member group

    visit edit_person_path(person)

    expect(page).to have_selector('.editable-fields', visible: :hidden)
    within('.editable-container') { click_link 'Change team' }
    expect(page).to have_selector('.editable-fields', visible: :visible)
    expect(page).to have_selector('.hide-editable-fields', visible: :visible)

    within('.team.selected') { click_link 'Back' }
    expect(page).to have_selector('a.subteam-link', text: /CSG/, visible: :visible)

    within('.team.selected') { click_link 'CSG' }
    click_link 'Done'
    expect(page).to have_selector('.editable-fields', visible: :hidden)

    click_button 'Save', match: :first

    person.reload
    expect(person.memberships.last.group).to eql(Group.find_by(name: 'CSG'))
  end

  it 'Adding a new team', js: true, user: :groups_editor do
    group = setup_three_level_team
    person = setup_team_member group

    visit edit_person_path(person)

    expect(page).to have_selector('.editable-fields', visible: :hidden)
    within('.editable-container') { click_link 'Change team' }
    expect(page).to have_selector('.editable-fields', visible: :visible)
    expect(page).to have_selector('.button-add-team', visible: :visible)

    find('a.button-add-team').click
    expect(page).to have_selector('.new-team', visible: :visible)
    within('.new-team') do
      fill_in 'AddTeam', with: 'New team'
    end
  end

  it 'Joining another team with a role', js: true do
    person = create_person_in_digital_justice
    create(:group, name: 'Communications', parent: Group.department)

    visit edit_person_path(person)

    click_link('Join another team')
    expect(page).to have_selector('.editable-fields', visible: :visible)

    within all('#memberships .membership').last do
      click_link 'Communications'
      fill_in 'Job title', with: 'Talker'
    end

    click_button 'Save', match: :first
    expect(Person.last.memberships.length).to be(2)
  end

  def check_leader(choice = 'Yes')
    within('.team-leader') do
      govuk_label_click(choice)
    end
  end

  it 'Adding a permanent secretary', js: true do
    person = create_person_in_digital_justice
    visit edit_person_path(person)
    fill_in 'First name', with: 'Samantha'
    fill_in 'Last name', with: 'Taylor'
    fill_in 'Job title', with: 'Permanent Secretary'

    expect(leader_question).to match('Is this person the leader of the Digital Justice team?')
    click_link 'Change team'
    select_in_team_select 'Ministry of Justice'
    expect(leader_question).to match('Are you the Permanent Secretary?')
    check_leader

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
    check_leader

    click_link('Join another team')
    expect(page).to have_selector('.editable-fields', visible: :visible)
    expect(leader_question).to match('Is this person the leader of the team?')
    select_in_team_select 'Digital Justice'
    expect(leader_question).to match('Is this person the leader of the Digital Justice team?')

    within last_membership do
      fill_in 'Job title', with: 'Master of None'
      check_leader
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

    visit edit_person_path(person)
    expect(person.memberships.count).to be 2
    expect(edit_profile_page).to have_selector('.membership.panel', visible: true, count: 2)
    within last_membership do
      click_link 'Leave team'
    end
    expect(edit_profile_page).to have_selector('.membership.panel', visible: true, count: 1)
    click_button 'Save'
    expect(current_path).to eql(person_path(person))
    expect(page).to have_content('Thank you for helping to improve People Finder')
    expect(person.reload.memberships.count).to be 1
  end

  it 'Leaving all teams', js: true do
    person = create_person_in_digital_justice
    visit edit_person_path(person)
    click_link('Leave team')
    click_button 'Save'
    expect(edit_profile_page).to have_error_summary
    expect(edit_profile_page.error_summary).to have_team_membership_required_error text: 'Membership of a team is required'
    expect(edit_profile_page.form).to have_team_membership_error_destination_anchor
    expect(person.reload.memberships.count).to be 1
  end
end

def create_person_in_digital_justice
  department = create(:department, name: 'Ministry of Justice')
  group = create(:group, name: 'Digital Justice', parent: department)
  person = create(:person, :member_of, team: group, sole_membership: true)
  person
end

def setup_three_level_team
  department = create(:department, name: 'Ministry of Justice')
  parent_group = create(:group, name: 'CSG', parent: department)
  create(:group, name: 'Technology', parent: parent_group)
  create(:group, name: 'Digital Services', parent: parent_group)
end

def setup_team_member(group)
  create(:person, :member_of, team: group, sole_membership: true)
end

def visit_edit_view(group)
  visit group_path(group)
  click_link 'Edit'
end
