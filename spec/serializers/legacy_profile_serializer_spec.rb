# frozen_string_literal: true

require 'rails_helper'

describe LegacyProfileSerializer do
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
    let(:data) { doc[:data] }
    let(:attributes) { data[:attributes] }
    let(:links) { data[:links] }

    it 'has the correct id and type' do
      expect(data[:id]).to eq(person.id)
      expect(data[:type]).to eq('people')
    end

    it 'contains the expected attributes' do
      expect(attributes[:name]).to eq(person.name)
      expect(attributes[:'given-name']).to eq(person.given_name)
      expect(attributes[:surname]).to eq(person.surname)
      expect(attributes[:email]).to eq(person.email)
      expect(attributes[:'completion-score']).to eq(person.completion_score)
    end

    it 'contains the expected links' do
      expect(links[:profile]).to eq(person_url(person))
      expect(links[:'edit-profile']).to eq(edit_person_url(person))
      expect(links[:'profile-image-url']).to match(/small_profile_photo_valid.png$/)
    end
  end
end
