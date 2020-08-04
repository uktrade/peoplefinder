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
    it { is_expected.to permit_action(:confirm) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:audit) }
  end

  context 'for a people editor' do
    let(:user) { build_stubbed(:people_editor) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:confirm) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:audit) }
  end

  context 'for an administrator' do
    let(:user) { build_stubbed(:administrator) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:confirm) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:audit) }
  end
end
