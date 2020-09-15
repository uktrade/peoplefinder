# frozen_string_literal: true

require 'rails_helper'

MANAGEMENT_ACTIONS = %i[show csv_extract_report sidekiq hr_data_imports].freeze

RSpec.describe Admin::ManagementPolicy, type: :policy do
  subject { described_class.new(user, nil) }

  context 'for an administrator' do
    let(:user) { build_stubbed(:administrator) }

    MANAGEMENT_ACTIONS.each do |action|
      it { is_expected.to permit_action(action) }
    end
  end

  context 'for a regular user' do
    let(:user) { build_stubbed(:person) }

    MANAGEMENT_ACTIONS.each do |action|
      it { is_expected.not_to permit_action(action) }
    end
  end
end
