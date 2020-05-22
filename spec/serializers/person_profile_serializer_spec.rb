# frozen_string_literal: true

require 'rails_helper'

describe PersonProfileSerializer do
  include Rails.application.routes.url_helpers

  subject { described_class.new(person) }

  let(:person) { create(:person, :with_photo) }

  describe '#as_json' do
    let(:doc) { subject.as_json }

    it 'contains the expected attributes' do
      expect(doc[:name]).to eq(person.name)
      expect(doc[:first_name]).to eq(person.given_name)
      expect(doc[:email]).to eq(person.email)
      expect(doc[:completion_score]).to eq(person.completion_score)
      expect(doc[:profile_url]).to eq(person_url(person))
      expect(doc[:profile_image_url]).to match(/small_profile_photo_valid.png$/)
    end
  end
end
