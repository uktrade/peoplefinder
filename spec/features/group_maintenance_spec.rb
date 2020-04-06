# frozen_string_literal: true

require 'rails_helper'

describe 'Group maintenance' do
  let!(:dept) { create(:department) }

  before(:each, user: :regular) do
    omni_auth_log_in_as '007'
  end

  before(:each, user: :groups_editor) do
    omni_auth_log_in_as_groups_editor
  end

  context 'for an administrator', user: :groups_editor, js: true do
    let(:group_three_deep) { create(:group, name: 'Digital Services', parent: parent_group) }
    let(:sibling_group) { create(:group, name: 'Technology', parent: parent_group) }
    let(:parent_group) { create(:group, name: 'CSG', parent: dept) }

    it 'Creating a team inside the department' do
      visit group_path(dept)
      click_link 'Add new sub-team'

      name = 'CSG'
      fill_in 'Team name', with: name
      click_button 'Save'

      expect(page).to have_content('Created CSG')

      team = Group.find_by(name: name)
      expect(team.name).to eql(name)
      expect(team.parent).to eql(dept)
    end

    it 'Creating a subteam inside a team from that team\'s page' do
      team = create(:group, parent: dept, name: 'Corporate Services')
      visit group_path(team)
      click_link 'Add new sub-team'

      name = 'Digital Services'
      fill_in 'Team name', with: name
      click_button 'Save'

      expect(page).to have_content('Created Digital Services')

      subteam = Group.find_by(name: name)
      expect(subteam.name).to eql(name)
      expect(subteam.parent).to eql(team)
    end

    it 'Deleting a team' do
      group = create(:group)
      visit edit_group_path(group)
      expect(page).to have_text('Delete team')
      accept_confirm do
        click_link('Delete this team')
      end

      expect(page).to have_content("Deleted #{group.name}")
      expect { Group.find(group.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'Prevent deletion of a team that has memberships' do
      membership = create(:membership)
      group = membership.group
      visit edit_group_path(group)
      expect(page).not_to have_link('Delete this team')
      expect(page).to have_text('You can only delete a team if it does not contain any people or sub-teams')
    end

    def setup_three_level_group
      sibling_group
      group_three_deep
    end

    def setup_group_member(group)
      user = create(:person)
      create :membership, person: user, group: group
      user
    end

    it 'Editing a team name' do
      group = setup_three_level_group
      visit edit_group_path(group)

      expect(page).to have_title("Edit team - #{app_title}")
      new_name = 'Cyberdigital Cyberservices'
      fill_in 'Team name', with: new_name

      click_button 'Save'

      expect(page).to have_content('Updated Cyberdigital Cyberservices')
      group.reload
      expect(group.name).to eql(new_name)
    end

    it 'Change parent to department via clicking "Back"' do
      group = setup_three_level_group
      setup_group_member group

      visit edit_group_path(group)

      within('.ws-team-browser') do
        click_button "Back to #{dept.name}"
        choose dept.name
      end

      click_button 'Save'

      group.reload
      expect(group.parent).to eql(dept)
    end

    it 'Changing a team parent via clicking sibling team name' do
      group = setup_three_level_group
      setup_group_member group

      visit edit_group_path(group)

      within('.ws-team-browser') do
        choose sibling_group.name
      end

      click_button 'Save'

      group.reload
      expect(group.parent).to eql(sibling_group)
    end

    it 'Changing a team parent via clicking sibling team\'s subteam name' do
      group = setup_three_level_group
      subteam_group = create(:group, name: 'Test team', parent: sibling_group)
      setup_group_member group
      group.memberships.reload # seems to help flicker
      visit edit_group_path(group)

      within('.ws-team-browser') do
        click_button sibling_group.name
        choose subteam_group.name
      end

      click_button 'Save'

      group.reload
      expect(group.parent).to eql(subteam_group)
    end

    it 'Showing the acronym' do
      group = create(:group, name: 'HM Courts and Tribunal Service', acronym: 'HMCTS')

      visit group_path(group)

      within('main') do
        expect(page).to have_text('HMCTS')
      end

      click_link 'Edit'
      fill_in 'Team acronym/initials', with: ''
      click_button 'Save'

      expect(page).not_to have_text('HMCTS')
    end

    it 'Not responding to the selection of impossible parent nodes' do
      parent_group = create(:group, name: 'CSG', parent: dept)
      group = create(:group, name: 'Digital Services', parent: parent_group)

      visit edit_group_path(group)

      within '.ws-team-browser' do
        choose 'Digital Services'
      end

      click_button 'Save'

      expect(page).to have_content('There is a problem')
      expect(page).to have_content('cannot be a descendant of itself')

      group.reload
      expect(group.parent).to eql(parent_group)
    end

    it 'UI elements on the new/edit pages' do
      create(:group, name: 'Child group', parent: dept)

      visit new_group_group_path(dept)

      fill_in 'Team name (required)', with: 'Digital'

      within '.ws-team-browser' do
        choose 'Child group'
      end

      click_button 'Save'
      expect(page).to have_link 'Edit team'
    end

    it 'Cancelling an edit' do
      group = create(:group)
      visit edit_group_path(group)
      expect(page).to have_link('Cancel', href: group_path(group))
    end

    it 'Not displaying an edit parent field for a department' do
      dept = create(:group).parent

      visit edit_group_path(dept)
      expect(page).not_to have_selector('.org-browser')
    end
  end

  context 'for a regular user', user: :regular do
    it 'Is not allowed to create a new team' do
      visit group_path(dept)
      expect(page).not_to have_link('Add new sub-team')

      visit new_group_group_path(dept)
      expect(page).to have_current_path(group_path(dept))

      within('#flash-messages') do
        expect(page).to have_content('Unauthorised')
      end
    end

    it 'Is not allowed to edit a team' do
      visit group_path(dept)
      expect(page).not_to have_link('Edit team')

      visit edit_group_path(dept)
      expect(page).to have_current_path(group_path(dept))

      within('#flash-messages') do
        expect(page).to have_content('Unauthorised')
      end
    end
  end
end
