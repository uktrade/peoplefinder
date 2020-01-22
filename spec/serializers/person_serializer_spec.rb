# frozen_string_literal: true

require 'rails_helper'

describe PersonSerializer do
  include Rails.application.routes.url_helpers

  subject { described_class.new(person) }

  let(:group) { create(:group, name: Faker::Company.name) }
  let(:role_title) { Faker::Job.title }
  let(:person) do
    create(
      :person,
      :with_photo,
      :member_of,
      team: group,
      role: role_title,
      primary_phone_country_code: 'GB',
      primary_phone_number: '0118 999 01199'
    )
  end

  describe '#as_json' do
    let(:doc) { subject.as_json }

    it 'has the correct ids' do
      expect(doc[:id]).to eq(person.id)
      expect(doc[:ditsso_user_id]).to eq(person.ditsso_user_id)
    end

    it 'contains the expected attributes' do
      expect(doc[:name]).to eq(person.name)
      expect(doc[:first_name]).to eq(person.given_name)
      expect(doc[:last_name]).to eq(person.surname)
      expect(doc[:email]).to eq(person.email)
      expect(doc[:phone_number]).to eq('+44 118 999 01199')
      expect(doc[:completion_score]).to eq(person.completion_score)
    end

    it 'contains the expected links' do
      expect(doc[:links][:profile_url]).to eq(person_url(person))
      expect(doc[:links][:edit_profile_url]).to eq(edit_person_url(person))
      expect(doc[:links][:profile_image_small]).to match(/small_profile_photo_valid.png$/)
      expect(doc[:links][:profile_image_medium]).to match(/medium_profile_photo_valid.png$/)
    end

    it 'contains the expected memberships' do
      expect(doc[:roles]).to include(group: group.name, role: role_title)
    end
  end
end
