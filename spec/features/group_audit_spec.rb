# frozen_string_literal: true

require 'rails_helper'

describe 'Auditing changes to groups' do
  let(:author) { create(:person) }
  let(:group) { create(:group) }

  before do
    with_versioning do
      PaperTrail.request.whodunnit = author.id

      group.update name: 'Updated name'
      group.update description: 'Updated description'
    end
  end

  context 'as a groups editor' do
    before do
      omni_auth_log_in_as_groups_editor
    end

    it 'displays changes to the group' do
      visit group_path(group)

      expect(page).to have_text 'Audit log'

      within('table tr:nth-child(2)') do
        expect(page).to have_text('description: Updated description')
      end

      within('table tr:nth-child(3)') do
        expect(page).to have_text('name: Updated name')
      end
    end

    it 'displays a link to the author of a change' do
      visit group_path(group)

      within('table tr:nth-child(2)') do
        expect(page).to have_link(author.to_s, href: person_path(author))
      end
    end
  end

  context 'as a regular user' do
    before do
      omni_auth_log_in_as('random user')
    end

    it 'does not display the audit log' do
      visit group_path(group)

      expect(page).not_to have_text 'Audit log'
    end
  end
end
