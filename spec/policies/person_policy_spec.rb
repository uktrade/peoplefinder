# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonPolicy, type: :policy do
  subject { described_class.new(user, person) }

  let(:person) { build_stubbed(:person) }

  context 'for a regular user' do
    let(:user) { build_stubbed(:person) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.to permit_action(:add_membership) }
  end

  context 'for a super admin user' do
    let(:user) { build_stubbed(:super_admin) }

    it { is_expected.to permit_action(:destroy) }
  end
end
