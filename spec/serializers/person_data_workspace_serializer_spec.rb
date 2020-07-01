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
        last_edited_or_confirmed_at login_count last_login_at people_finder_id staff_sso_id full_name first_name
        last_name primary_phone_number secondary_phone_number formatted_location location_other_uk
        location_other_overseas buildings formatted_buildings roles formatted_roles key_skills formatted_key_skills
        other_key_skills learning_and_development other_learning_and_development formatted_learning_and_development
        networks formatted_networks professions formatted_professions additional_responsibilities
        other_additional_responsibilities formatted_additional_responsibilities manager_people_finder_id
        completion_score profile_url country_name formatted_grade is_stale
      ]
    end

    it 'has the appropriate keys' do
      expect(json_hash).to include(*expected_keys)
    end
  end
end
