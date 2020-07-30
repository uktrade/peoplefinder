# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Membership, type: :model do
  subject { described_class.new }

  let(:moj) { create :department, name: 'Ministry of Justice' }

  it { is_expected.to validate_presence_of(:person).on(:update) }
  it { is_expected.to validate_presence_of(:group).on(:update) }

  it 'is not a leader by default' do
    expect(subject).not_to be_leader
  end

  # The Permanent Secretary is whomever has a membership indicating
  # that they are the leader of the top-most team (a.k.a department,
  # Ministry of Justice)
  #
  context 'validates uniqueness of Permanent Secretary' do
    let(:csg) { create :group, name: 'Corporate Services Group' }
    let(:person) { create :person, :member_of, team: csg }
    let(:membership) { person.memberships.first }

    context 'when a perm. sec. already exists' do
      let!(:boss) { create :person, :member_of, team: moj, leader: true, role: 'Perm. Sec.' }

      it 'permits changing team to department' do
        membership.group_id = moj.id
        expect(membership).to be_valid
      end

      it 'permits becoming leader of sub-department' do
        membership.leader = true
        expect(membership).to be_valid
      end

      it 'permits changing perm. sec. to not being the perm. sec.' do
        membership = boss.memberships.first
        membership.leader = false
        expect(membership).to be_valid
      end

      it 'permits updates to perm. sec.' do
        membership = boss.memberships.first
        expect(membership).to be_valid
      end

      it 'prevents new memberships as perm. sec.' do
        membership = build(:membership, person: person, group: moj, leader: true, role: 'another perm sec')
        expect(membership).to be_invalid
      end

      it 'prevents changing team to department if you are a leader' do
        membership.leader = true
        expect(membership).to be_valid
        membership.group_id = moj.id
        expect(membership).to be_invalid
      end

      it 'adds appropriate error message to leader attribute' do
        membership = build(:membership, person: person, group: moj, leader: true, role: 'Boss')
        membership.valid?
        expect(membership.errors[:leader]).to include(/Ministry of Justice can only have one leader, and there already is one/)
      end
    end

    context 'when a perm. sec. does not exist' do
      it 'permits becoming perm. sec.' do
        membership.group_id = moj.id
        membership.leader = true
        expect(membership).to be_valid
      end
    end
  end
end
