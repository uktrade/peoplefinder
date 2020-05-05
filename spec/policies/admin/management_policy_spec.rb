# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ManagementPolicy, type: :policy do
  subject { described_class.new(user, nil) }

  ACTIONS = %i[show csv_extract_report sidekiq].freeze

  context 'for an administrator' do
    let(:user) { build_stubbed(:administrator) }

    ACTIONS.each do |action|
      it { is_expected.to permit_action(action) }
    end
  end

  context 'for a regular user' do
    let(:user) { build_stubbed(:person) }

    ACTIONS.each do |action|
      it { is_expected.not_to permit_action(action) }
    end
  end
end
