# frozen_string_literal: true

require 'rails_helper'

describe 'View person audit' do
  let(:super_admin_email) { 'test.user@digital.justice.gov.uk' }
  let!(:super_admin) { create(:super_admin, email: super_admin_email) }

  let(:phone_number) { '55555555555' }
  let!(:person)      { with_versioning { create(:person) } }
  let(:profile_page) { Pages::Profile.new }

  let(:profile_photo) { create(:profile_photo) }

  let(:author) { create(:person) }

  context 'modern versioning' do
    before do
      with_versioning do
        PaperTrail.request.whodunnit = author.id
        person.update primary_phone_number: phone_number
        person.update profile_photo_id: profile_photo.id
      end
    end

    context 'as an admin user' do
      before do
        omni_auth_log_in_as(super_admin.ditsso_user_id)
      end

      it 'view audit' do
        profile_page.load(slug: person.slug)

        expect(profile_page).to have_audit
        profile_page.audit.versions.tap do |v|
          expect(v[0]).to have_text "profile_photo_id: #{profile_photo.id}"
          expect(v[1]).to have_text "primary_phone_number: #{phone_number}"
          expect(v[2]).to have_text "email: #{person.email}"
        end
      end

      it 'link to author of a change' do
        profile_page.load(slug: person.slug)

        profile_page.audit.versions.tap do |v|
          expect(v[0]).to have_link author.to_s, href: "/people/#{author.slug}"
        end
      end
    end

    context 'as a regular user' do
      before do
        omni_auth_log_in_as(person.ditsso_user_id)
      end

      it 'hide audit' do
        profile_page.load(slug: person.slug)
        expect(profile_page).not_to have_audit
      end
    end
  end
end
