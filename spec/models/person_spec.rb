# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person, type: :model do
  let(:person) { build(:person) }

  it { is_expected.to validate_presence_of(:given_name).on(:update) }
  it { is_expected.to validate_presence_of(:surname) }
  it { is_expected.to validate_presence_of(:ditsso_user_id) }
  it { is_expected.to validate_uniqueness_of(:ditsso_user_id) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to have_many(:groups) }

  it { is_expected.to respond_to(:skip_group_completion_score_updates) }

  context 'test factory' do
    describe '#create(:person)' do
      let(:person) { create(:person) }

      it 'creates a valid person' do
        expect(person).to be_valid
      end

      it 'defaults team membership to department level' do
        expect(person.memberships.map(&:group)).to include Group.department
      end
    end
  end

  describe '#phone_number_variations' do
    subject do
      build(
        :person,
        primary_phone_number: phone_number,
        primary_phone_country_code: country_code
      )
    end

    let(:phone_number) { '0118 999-881 999 119 (725) ext. 3' }
    let(:country_code) { 'GB' }

    it 'returns the expected variatons' do
      expect(subject.phone_number_variations).to eq(
        %w[
          01189998819991197253
          441189998819991197253
        ]
      )
    end

    context 'when no country is provided' do
      let(:country_code) { nil }

      it 'returns only the country code-less variation' do
        expect(subject.phone_number_variations).to eq(
          %w[
            01189998819991197253
          ]
        )
      end
    end

    context 'when the phone number does not start with "0"' do
      let(:phone_number) { '123456' }

      it 'returns the expected variatons' do
        expect(subject.phone_number_variations).to eq(
          %w[
            123456
            44123456
            0123456
          ]
        )
      end
    end

    context 'when no phone number is provided' do
      let(:phone_number) { nil }

      it 'returns nil' do
        expect(subject.phone_number_variations).to be_nil
      end
    end
  end

  describe '#email' do
    it 'raises an invalid format error if present but invalid' do
      person = build :person, email: 'sdsdsdsds'
      expect(person.save).to be false
      expect(person.errors[:email]).to eq(['is invalid'])
    end

    it 'is converted to lower case' do
      person = create(:person, email: 'User.Example@digital.justice.gov.uk')
      expect(person.email).to eq 'user.example@digital.justice.gov.uk'
    end
  end

  describe '#name' do
    context 'with a given_name and surname' do
      let(:person) { build(:person, given_name: 'Jon', surname: 'von Brown') }

      it 'concatenates given_name and surname' do
        expect(person.name).to eql('Jon von Brown')
      end
    end

    context 'with a surname only' do
      let(:person) { build(:person, given_name: '', surname: 'von Brown') }

      it 'uses the surname' do
        expect(person.name).to eql('von Brown')
      end
    end

    context 'with surname containing digit' do
      let(:person) { build(:person, given_name: 'John', surname: 'Smith2') }

      it 'removes digit' do
        person.valid?
        expect(person.name).to eql('John Smith')
      end
    end
  end

  describe '.all_in_subtree' do
    let!(:team) { create(:group) }
    let!(:subteam) { create(:group, parent: team) }

    let!(:person1) { create(:person, :member_of, team: team, role: 'A role') }
    let!(:person2) { create(:person, :member_of, team: subteam, role: 'Another role') }

    before do
      person1.memberships.create(group: team, role: 'Side gig')
    end

    it 'returns people with aggregate role_names column' do
      expect(described_class.all_in_subtree(team).map(&:role_names))
        .to contain_exactly('A role, Side gig', 'Another role')
    end
  end

  describe '.all_in_groups' do
    let(:groups) { create_list(:group, 3) }
    let(:people) { create_list(:person, 3) }

    it 'returns all people in any listed groups and .count_in_groups returns correct count' do
      people.zip(groups).each do |person, group|
        create :membership, person: person, group: group
      end
      group_ids = groups.take(2)
      result = described_class.all_in_groups(group_ids)
      expect(result).to include(people[0])
      expect(result).to include(people[1])
      expect(result).not_to include(people[2])

      count = described_class.count_in_groups(group_ids)
      expect(count).to eq(2)

      count = described_class.count_in_groups(group_ids, excluded_group_ids: groups.take(1))
      expect(count).to eq(1)
    end

    it 'concatenates all roles alphabetically with commas' do
      create :membership, person: people[0], group: groups[0], role: 'Prison chaplain'
      create :membership, person: people[0], group: groups[1], role: 'Head of crime'
      result = described_class.all_in_groups(groups.take(2))
      expect(result[0].role_names).to eq('Head of crime, Prison chaplain')
    end

    it 'omits blank roles' do
      create :membership, person: people[0], group: groups[0], role: 'Prison chaplain'
      create :membership, person: people[0], group: groups[1], role: ''
      result = described_class.all_in_groups(groups.take(2))
      expect(result[0].role_names).to eq('Prison chaplain')
    end

    it 'includes each person only once' do
      create :membership, person: people[0], group: groups[0], role: 'Prison chaplain'
      create :membership, person: people[0], group: groups[1], role: 'Head of crime'
      result = described_class.all_in_groups(groups.take(2))
      expect(result.length).to eq(1)
    end
  end

  describe '#slug' do
    it 'generates from the first part of the email address if present' do
      person = create(:person, email: 'user.example@digital.justice.gov.uk')
      person.reload
      expect(person.slug).to eql(Digest::SHA1.hexdigest('user.example'))
    end
  end

  context 'search' do
    it 'deletes indexes' do
      expect(described_class.__elasticsearch__).to receive(:delete_index!)
        .with(index: 'test_people')
      described_class.delete_indexes
    end
  end

  context 'elasticsearch indexing helpers' do
    before do
      person.save!
      digital_services = create(:group, name: 'Digital Services')
      estates = create(:group, name: 'Estates')
      person.memberships.create(group: estates, role: 'Cleaner')
      person.memberships.create(group: digital_services, role: 'Designer')
    end

    it 'writes the role and group as a string' do
      expect(person.role_and_group).to match(/Digital Services, Designer/)
      expect(person.role_and_group).to match(/Estates, Cleaner/)
    end
  end

  context 'group member completion score update' do
    include ActiveJob::TestHelper

    let(:person) { build(:person) }
    let!(:digital_services) { create(:group, name: 'Digital Services') }

    before do
      person.save!
      person.memberships.create(group: digital_services, role: 'Service Assessments Lead')
      person.save!
      person.primary_phone_number = '00222'
      clear_enqueued_jobs
    end

    it 'enqueues the UpdateGroupMembersCompletionScoreJob' do
      expect { person.save! }.to have_enqueued_job(UpdateGroupMembersCompletionScoreJob).with(digital_services)
    end
  end

  context 'with two memberships in the same group' do
    before do
      person.save!
      person.memberships.destroy_all
      digital_services = create(:group, name: 'Digital Services')
      person.memberships.create(group: digital_services, role: 'Service Assessments Lead')
      person.memberships.create(group: digital_services, role: 'Head of Delivery')
      person.reload
    end

    it 'allows updates to those memberships' do
      membership = person.memberships.first
      expect(membership.leader).to be false

      membership_attributes = membership.attributes
      person.assign_attributes(
        memberships_attributes: {
          membership_attributes[:id] => membership_attributes.merge(leader: true)
        }
      )
      person.save!
      updated_membership = person.reload.memberships.find(membership.id)
      expect(updated_membership.leader).to be true
    end

    it 'fires UpdateGroupMembersCompletionScoreJob for group on save' do
      expect(UpdateGroupMembersCompletionScoreJob).to receive(:perform_later).with(person.groups.first)
      person.save
    end
  end

  describe '#path' do
    let(:person) { described_class.new }

    context 'when there are no memberships' do
      it 'contains only itself' do
        expect(person.path).to eql([person])
      end
    end

    context 'when there is one membership' do
      it 'contains the group path' do
        group_a = build(:group)
        group_b = build(:group)
        allow(group_b).to receive(:path) { [group_a, group_b] }
        person.groups << group_b
        expect(person.path).to eql([group_a, group_b, person])
      end
    end

    context 'when there are multiple group memberships' do
      let(:groups) { 4.times.map { build(:group) } }

      before do
        allow(groups[1]).to receive(:path) { [groups[0], groups[1]] }
        allow(groups[3]).to receive(:path) { [groups[2], groups[3]] }
        person.groups << groups[1]
        person.groups << groups[3]
      end

      it 'uses the first group path' do
        expect(person.path).to eql([groups[0], groups[1], person])
      end
    end
  end

  describe '#phone' do
    let(:person) { create(:person) }
    let(:primary_phone_number) { '0207-123-4567' }
    let(:secondary_phone_number) { '0208-999-8888' }

    context 'with a primary and secondary phone' do
      before do
        person.primary_phone_number = primary_phone_number
        person.secondary_phone_number = secondary_phone_number
      end

      it 'uses the primary phone number' do
        expect(person.phone).to eql(primary_phone_number)
      end
    end

    context 'with a blank primary and a valid secondary phone' do
      before do
        person.primary_phone_number = ''
        person.secondary_phone_number = secondary_phone_number
      end

      it 'uses the secondary phone number' do
        expect(person.phone).to eql(secondary_phone_number)
      end
    end
  end

  describe '#location' do
    it 'concatenates location_in_building, location, and city' do
      person.location_in_building = '99.99'
      person.building = '102 Petty France'
      person.city = 'London'
      expect(person.location).to eq('99.99, London')
    end

    it 'skips blank fields' do
      person.location_in_building = 'At home'
      person.building = ''
      person.city = nil
      expect(person.location).to eq('At home')
    end
  end

  describe '#notify_of_change?' do
    it 'is true if there is no reponsible person' do
      expect(person.notify_of_change?(nil)).to be true
    end

    it 'is false if the reponsible person is this person' do
      expect(person.notify_of_change?(person)).to be false
    end

    it 'is true if the reponsible person is a third party' do
      other_person = build(:person)
      expect(person.notify_of_change?(other_person)).to be true
    end
  end

  describe '#profile_image' do
    context 'when there is a profile photo' do
      it 'delegates to the profile photo' do
        profile_photo = create(:profile_photo)
        person.profile_photo = profile_photo
        expect(person.profile_image).to eq(profile_photo.image)
      end
    end

    context 'when there is no image' do
      it 'returns nil' do
        expect(person.profile_image).to be_nil
      end
    end
  end

  describe '#skip_group_completion_score_updates' do
    before do
      digital_services = create(:group, name: 'Digital Services')
      person.memberships.build(group: digital_services)
      person.skip_group_completion_score_updates = true
    end

    it 'prevents enqueuing of group completion score update job for bulk upload purposes' do
      expect(UpdateGroupMembersCompletionScoreJob).not_to receive(:perform_later)
      person.save
    end
  end

  describe '#primary_phone_country' do
    it 'returns an instance of ISO3166::Country when a value is present' do
      person.primary_phone_country_code = 'GB'

      expect(person.primary_phone_country).to eq(ISO3166::Country.new('GB'))
    end

    it 'returns nil when a value is not present' do
      person.primary_phone_country_code = nil

      expect(person.primary_phone_country).to be_nil
    end
  end
end
