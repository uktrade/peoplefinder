# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupPolicy, type: :policy do
  subject { described_class.new(user, group) }

  let(:group) { build_stubbed(:group) }

  context 'for a regular user' do
    let(:user) { build_stubbed(:person) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:all_people) }
    it { is_expected.to permit_action(:people_outside_subteams) }
    it { is_expected.to permit_action(:tree) }
    it { is_expected.not_to permit_action(:edit) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:new) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  context 'for a super admin' do
    let(:user) { build_stubbed(:super_admin) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:all_people) }
    it { is_expected.to permit_action(:people_outside_subteams) }
    it { is_expected.to permit_action(:tree) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:destroy) }
  end
end
