# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Completion do
  let(:completed_attributes) do
    {
      given_name: 'Bobby',
      surname: 'Tables',
      email: 'user.example@digital.justice.gov.uk',
      primary_phone_number: '020 7946 0123',
      location_in_building: '13.13',
      country: 'GB',
      city: 'London',
      profile_photo_id: profile_photo.id,
      line_manager_id: 666
    }
  end

  let(:profile_photo) do
    create(:profile_photo)
  end

  let(:person) do
    create(:person)
  end

  describe '#completion_score' do
    it 'returns 0 if all fields are empty' do
      person = Person.new
      expect(person.completion_score).to be(0)
      expect(person).to be_incomplete
    end

    it 'returns non-zero for any persisted person' do
      expect(person.completion_score).not_to eq 0
    end

    it 'returns higher score if a group is assigned' do
      person.memberships.destroy_all
      initial = person.completion_score
      create(:membership, person: person)
      expect(person.completion_score).to be > initial
    end

    it 'returns the same score if a line manager is completed as when the "not required" field is present' do
      person_with_line_manager = create(:person, :with_line_manager)
      person_with_line_manager_not_required = create(:person, line_manager_not_required: true)

      expect(person_with_line_manager.completion_score).to eq(person_with_line_manager_not_required.completion_score)
    end

    it 'returns an appropriate score if half the fields are completed' do
      person = create(:person, city: generate(:city), country: nil, primary_phone_number: generate(:phone_number))
      person.memberships.destroy_all
      expect(person.completion_score).to be_within(1).of(56)
      expect(person).to be_incomplete
    end

    context 'when all the fields are completed' do
      let(:person) { create(:person, completed_attributes) }

      before { create(:membership, person: person) }

      it 'returns 100' do
        expect(person.completion_score).to be(100)
        expect(person).not_to be_incomplete
      end
    end
  end

  describe '.overall_completion' do
    it 'calls method encapsulating contruction of raw SQL for average completion score' do
      expect(Person).to receive(:average_completion_score)
      Person.overall_completion
    end

    it 'returns 100 if there is only one person who is 100% complete' do
      person = create(:person, completed_attributes)
      create(:membership, person: person)
      expect(Person.overall_completion).to eq(100)
    end

    it 'returns average of two profiles completion scores' do
      create_list(
        :person,
        2,
        given_name: generate(:given_name),
        surname: generate(:surname),
        email: generate(:email),
        city: generate(:city),
        primary_phone_number: generate(:phone_number)
      )

      expect(Person.overall_completion).to be_within(1).of(67)
    end

    it 'includes membership in calculation' do
      people = Array.new(2) do
        person = create(
          :person,
          given_name: generate(:given_name),
          surname: generate(:surname),
          email: generate(:email),
          city: generate(:city),
          primary_phone_number: generate(:phone_number)
        )
        person.memberships.destroy_all
        person
      end
      expect(UpdateGroupMembersCompletionScoreWorker).to receive(:perform_async).at_least(:once)
      create_list(:membership, 2, person: people[0])
      people.each(&:reload)
      expect(people[0].completion_score).to be_within(1).of(67)
      expect(people[1].completion_score).to be_within(1).of(56)
      expect(Person.overall_completion).to be_within(1).of(61)
    end
  end

  describe '.completion_score_calculation' do
    it 'constructs sql to calculate score based on existence of values for important fields' do
      sql_regex = /COALESCE.*CASE WHEN length\(.*,0\)\)::float.*/mi
      expect(Person.completion_score_calculation).to match(sql_regex)
    end

    it 'uses number of COMPLETION_FIELDS to calculate fraction part of the whole' do
      expect(Person::COMPLETION_FIELDS).to receive(:size)
      Person.completion_score_calculation
    end
  end

  describe '.average_completion_score' do
    it 'executes raw SQL for scalability/performance' do
      conn = double.as_null_object
      expect(ActiveRecord::Base).to receive(:connection).at_least(:once).and_return(conn)
      expect(conn).to receive(:execute).with(/^\s*SELECT AVG\(.*$/i)
      Person.average_completion_score
    end

    it 'returns a rounded float for use as a percentage' do
      create(:person, :with_details)
      expect(Person.average_completion_score).to be 78
    end
  end

  describe '.inadequate_profiles' do
    subject { Person.inadequate_profiles }

    let!(:person) { create(:person, completed_attributes) }

    it 'is empty when all attributes are populated' do
      expect(subject).to be_empty
    end

    it 'returns the person when there is no primary phone number' do
      Person.update_all 'primary_phone_number = \'\''
      expect(subject).to include(person)
    end

    it 'returns the person when there is no building' do
      Person.update_all 'country = \'\''
      expect(subject).to include(person)
    end

    it 'returns the person when there is no city' do
      Person.update_all 'city = \'\''
      expect(subject).to include(person)
    end

    it 'returns the person when there is no image' do
      Person.update_all 'profile_photo_id = null'
      expect(subject).to include(person)
    end
  end
end
