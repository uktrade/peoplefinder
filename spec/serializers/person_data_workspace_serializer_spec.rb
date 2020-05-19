# frozen_string_literal: true

require 'rails_helper'

describe PersonDataWorkspaceSerializer do
  subject { described_class.new(person) }

  let(:person) { build_stubbed(:person) }

  describe '#as_json' do
    let(:json_hash) { subject.as_json }
    let(:expected_keys) do
      %w[
        email skype_name works_monday works_tuesday works_wednesday works_thursday works_friday works_saturday
        works_sunday location_in_building city country language_fluent language_intermediate grade created_at
        last_edited_or_confirmed_at people_finder_id staff_sso_id full_name first_name last_name primary_phone_number
        secondary_phone_number location_other_uk location_other_overseas place_of_work roles key_skills
        learning_and_development networks professions additional_responsibilities manager_people_finder_id
        completion_score profile_url
      ]
    end

    it 'has the appropriate keys' do
      expect(json_hash).to include(*expected_keys)
    end
  end
end
