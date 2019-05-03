# frozen_string_literal: true

require 'rails_helper'

describe 'Google Analytics tracking' do
  let(:person) { create :person }
  let(:group) { create :group }

  context 'Edit profile links' do
    before do
      omni_auth_log_in_as '007'
      visit person_path(person)
    end

    it 'have event data to pass to GA' do
      expect(page.find_all('[data-event-category]').map(&:text)).to include 'Edit this profile', 'complete this profile'
    end
    it 'have virtual-pageview data to pass GA' do
      expect(page.find_all('[data-virtual-pageview]').map(&:text)).to include 'Edit this profile', 'complete this profile'
    end
  end

  context 'Edit team links' do
    before do
      omni_auth_log_in_as_super_admin
      visit group_path(group)
    end

    it 'have event data to pass to GA' do
      expect(page.find_all('[data-event-category]').map(&:text)).to include 'Edit this team'
    end
    it 'have virtual-pageview data to pass GA' do
      expect(page.find_all('[data-virtual-pageview]').map(&:text)).to include 'Edit this team'
    end
  end
end
