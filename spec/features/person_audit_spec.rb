# frozen_string_literal: true

require 'rails_helper'

describe 'View person audit' do
  let(:phone_number) { '55555555555' }
  let!(:person) { with_versioning { create(:person) } }
  let(:profile_page) { Pages::Profile.new }

  let(:profile_photo) { create(:profile_photo) }

  let(:author) { create(:person) }

  context 'as a people editor' do
    before do
      omni_auth_log_in_as_people_editor

      with_versioning do
        PaperTrail.request.whodunnit = author.id
        person.update primary_phone_number: phone_number
        person.update profile_photo_id: profile_photo.id
      end
    end

    it 'shows audit' do
      visit person_path(person)

      expect(page).to have_text('Audit log')

      within('table tr:nth-child(2)') do
        expect(page).to have_link(author.to_s, href: "/people/#{author.slug}")
      end

      within('table tr:nth-child(2)') do
        expect(page).to have_text("profile_photo_id: #{profile_photo.id}")
      end

      within('table tr:nth-child(3)') do
        expect(page).to have_text("primary_phone_number: #{phone_number}")
      end

      within('table tr:nth-child(4)') do
        expect(page).to have_text("email: #{person.email}")
      end
    end
  end

  context 'as a regular user' do
    before do
      omni_auth_log_in_as(person.ditsso_user_id)
    end

    it 'does not show audit' do
      visit person_path(person)

      expect(page).not_to have_text('Audit log')
    end
  end
end
