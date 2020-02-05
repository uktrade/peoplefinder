# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ManagementPolicy, type: :policy do
  subject { described_class.new(user, nil) }

  ACTIONS = %w[show csv_extract_report].map(&:to_sym)

  context 'for a super admin user' do
    let(:user) { build_stubbed(:person, super_admin: true) }

    ACTIONS.each do |action|
      it { is_expected.to permit_action(action) }
    end
  end

  context 'for a regular user' do
    let(:user) { build_stubbed(:person, super_admin: false) }

    ACTIONS.each do |action|
      it { is_expected.not_to permit_action(action) }
    end
  end
end
