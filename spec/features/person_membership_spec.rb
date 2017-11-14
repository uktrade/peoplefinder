require 'rails_helper'

feature "Person maintenance" do
  include PermittedDomainHelper

  before do
    omni_auth_log_in_as 'test.user@digital.justice.gov.uk'
  end

  before(:each, user: :super_admin) do
    omni_auth_log_in_as_super_admin
  end

  let(:edit_profile_page) { Pages::EditProfile.new }

  scenario 'Creating a person and making them the leader of a group', js: true do
    group = create(:group, name: 'Digital Justice')
    javascript_log_in

    visit new_person_path
    fill_in 'First name', with: 'Helen'
    fill_in 'Last name', with: 'Taylor'
    fill_in 'Primary work email', with: person_attributes[:email]
    fill_in_extended_required_fields
    select_in_team_select 'Digital Justice'
    check_leader
    click_button 'Save', match: :first

    membership = Person.last.memberships.last
    expect(membership.role).to eql('Head Honcho')
    expect(membership.group).to eql(group)
    expect(membership.leader?).to be true
    expect(membership).to be_subscribed

    visit group_path(group)
    within('.cb-leaders') do
      expect(page).to have_selector('h4', text: 'Taylor')
      expect(page).to have_text('Head Honcho')
    end
  end

  xscenario 'Confirming an identical person with membership details', js: true do
    create(:group, name: 'Digital Justice')
    create(:person, given_name: person_attributes[:given_name], surname: person_attributes[:surname])

    javascript_log_in
    visit new_person_path
    fill_in_complete_profile_details
    fill_in_extended_required_fields
    click_button 'Save', match: :first

    expect(page).to have_text('1 result found')
    click_button 'Continue'

    # step through the form again to complete the required fields
    fill_in_extended_required_fields
    click_button 'Save', match: :first

    duplicate = Person.find_by(email: person_attributes[:email])
    expect(duplicate.memberships.last).to have_attributes membership_attributes
  end

  scenario 'Editing a job title', js: true do
    person = create_person_in_digital_justice

    javascript_log_in
    visit edit_person_path(person)
    expect(page).to have_selector('.team-led', text: 'Digital Justice team')
    fill_in_extended_required_fields
    fill_in 'Job title', match: :first, with: 'Head Honcho'
    click_button 'Save', match: :first

    membership = Person.last.memberships.last
    expect(membership.role).to eql('Head Honcho')
    expect(page).to have_selector('.cb-job-title', text: 'Head Honcho in Digital Justice')
  end

  scenario 'Leaving the job title blank', js: true do
    person = create_person_in_digital_justice

    javascript_log_in
    visit edit_person_path(person)
    fill_in_extended_required_fields
    expect(page).to have_selector('.team-led', text: 'Digital Justice team')

    fill_in 'Job title', with: ''

    click_button 'Save', match: :first

    within('.profile') { expect(page).not_to have_selector('.cb-job-title') }
  end

  scenario 'Changing team membership via clicking "Back"', js: true do
    group = setup_three_level_team
    person = setup_team_member group

    javascript_log_in
    visit edit_person_path(person)
    fill_in_extended_required_fields

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

  scenario 'Adding a new team', js: true, user: :super_admin do
    group = setup_three_level_team
    person = setup_team_member group

    javascript_log_in
    visit edit_person_path(person)
    fill_in_extended_required_fields

    expect(page).to have_selector('.editable-fields', visible: :hidden)
    within('.editable-container') { click_link 'Change team' }
    expect(page).to have_selector('.editable-fields', visible: :visible)
    expect(page).to have_selector('.button-add-team', visible: :visible)

    find('a.button-add-team').trigger('click')
    expect(page).to have_selector('.new-team', visible: :visible)
    within('.new-team') do
      fill_in 'AddTeam', with: 'New team'
    end
  end

  scenario 'Joining another team with a role', js: true do
    person = create_person_in_digital_justice
    create(:group, name: 'Communications', parent: Group.department)

    javascript_log_in
    visit edit_person_path(person)
    fill_in_extended_required_fields

    click_link('Join another team')
    expect(page).to have_selector('.editable-fields', visible: :visible)

    within all('#memberships .membership').last do
      click_link 'Communications'
      fill_in 'Job title', with: 'Talker'
    end

    click_button 'Save', match: :first
    expect(Person.last.memberships.length).to eql(2)
  end

  def check_leader(choice = 'Yes')
    within('.team-leader') do
      govuk_label_click(choice)
    end
  end

  scenario 'Adding a permanent secretary', js: true do
    person = create_person_in_digital_justice
    javascript_log_in
    visit edit_person_path(person)
    fill_in 'First name', with: 'Samantha'
    fill_in 'Last name', with: 'Taylor'
    fill_in 'Job title', with: 'Permanent Secretary'
    fill_in_extended_required_fields

    expect(leader_question).to match('Is this person the leader of the Digital Justice team?')
    click_link 'Change team'
    select_in_team_select 'Ministry of Justice'
    expect(leader_question).to match('Are you the Permanent Secretary?')
    check_leader

    click_button 'Save', match: :first

    visit group_path(Group.find_by(name: 'Ministry of Justice'))
    within('.cb-leaders') do
      expect(page).to have_selector('h4', text: 'Samantha Taylor')
      expect(page).to have_text('Permanent Secretary')
    end

    visit person_path(person)
    expect(page).to have_selector('h3', text: 'Permanent Secretary')

    visit home_path
    expect(page.find('#content img.media-object')[:alt]).to have_content 'Current photo of Samantha Taylor'
  end

  scenario 'Adding an additional leadership role in same team', js: true do
    person = create_person_in_digital_justice
    javascript_log_in
    visit edit_person_path(person)
    fill_in 'First name', with: 'Samantha'
    fill_in 'Last name', with: 'Taylor'
    fill_in 'Job title', with: 'Head Honcho'
    fill_in_extended_required_fields
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

    visit group_path(Group.find_by_name('Digital Justice'))
    within('.cb-leaders') do
      expect(page).to have_selector('h4', text: 'Samantha Taylor')
      expect(page).to have_text('Head Honcho, Master of None')
    end

    visit person_path(person)
    expect(page).to have_selector('h3', text: 'Head Honcho, Master of None')
  end

  scenario 'Unsubscribing from notifications', js: true do
    person = create_person_in_digital_justice

    javascript_log_in
    visit edit_person_path(person)
    fill_in_extended_required_fields

    fill_in 'Job title', with: 'Head Honcho'
    within('.team-subscribed') { govuk_label_click('No') }
    click_button 'Save', match: :first

    membership = Person.last.memberships.last
    expect(membership).not_to be_subscribed
  end

  scenario 'Clicking Join another team', js: true do
    create(:group)

    javascript_log_in
    visit new_person_path

    click_link('Join another team')
    expect(page).to have_selector('#memberships .membership', count: 2)
  end

  scenario 'Clicking Leave team', js: true do
    create(:group)

    javascript_log_in
    visit new_person_path

    click_link('Leave team', match: :first)
    expect(page).to have_selector('#memberships .membership', count: 0)
  end

  scenario 'Leaving a team', js: true do
    ds = create(:group, name: 'Digital Justice')
    person = create(:person, :member_of, team: ds, role: 'tester', sole_membership: false)

    javascript_log_in
    visit edit_person_path(person)
    fill_in_extended_required_fields

    expect(person.memberships.count).to eql 2
    expect(edit_profile_page).to have_selector('.membership.panel', visible: true, count: 2)
    within last_membership do
      click_link 'Leave team'
    end
    expect(edit_profile_page).to have_selector('.membership.panel', visible: true, count: 1)
    click_button 'Save'
    expect(current_path).to eql(person_path(person))
    expect(page).to have_content("Thank you for helping to improve People Finder")
    expect(person.reload.memberships.count).to eql 1
  end

  scenario 'Leaving all teams', js: true do
    person = create_person_in_digital_justice
    javascript_log_in
    visit edit_person_path(person)
    fill_in_extended_required_fields

    click_link('Leave team')
    click_button 'Save'
    expect(edit_profile_page).to have_error_summary
    expect(edit_profile_page.error_summary).to have_team_membership_required_error text: 'Membership of a team is required'
    expect(edit_profile_page.form).to have_team_membership_error_destination_anchor
    expect(person.reload.memberships.count).to eql 1
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

def setup_team_member group
  create(:person, :member_of, team: group, subscribed: true, sole_membership: true)
end

def visit_edit_view group
  javascript_log_in
  visit group_path(group)
  click_link 'Edit'
end

def fill_in_extended_required_fields
  fill_in 'Phone number', with: '077777'
  fill_in 'Town, City or Region', with: 'London'
  fill_in 'Fluent languages', with: 'English'
  select 'Apprentice', from: 'Grade'
  fill_in 'Job title', with: 'Head Honcho'
end
