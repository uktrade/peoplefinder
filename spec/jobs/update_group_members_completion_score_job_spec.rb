# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateGroupMembersCompletionScoreJob, type: :job do
  include ActiveJob::TestHelper

  let(:parent) { nil }
  let(:group) { double(parent: parent) }

  context 'enqueuing' do
    subject { proc { described_class.perform_later(group) } }

    let!(:group) { create(:group) }

    it 'enqueues on low priority queue' do
      expect(subject).to have_enqueued_job(described_class).on_queue('default')
    end

    it 'enqueues with group params' do
      expect(subject).to have_enqueued_job.with(group)
    end
  end

  describe '#error_handler' do
    subject(:enqueue_job) { described_class.perform_later(group) }

    let!(:group) { create(:group) }

    before { group.destroy! }

    it 'rescues from ActiveJob::DeserializationError' do
      expect_any_instance_of(described_class).to receive(:error_handler).with(ActiveJob::DeserializationError)
      perform_enqueued_jobs { enqueue_job }
    end

    it 'tests if original exception arises from deleted records' do
      expect_any_instance_of(ActiveJob::DeserializationError).to receive(:cause).and_return(ActiveRecord::RecordNotFound)
      perform_enqueued_jobs { enqueue_job }
    end
  end

  context 'when called' do
    let(:group) { create :group }
    let(:parent) { group.parent }

    before do
      allow(group).to receive(:update_members_completion_score!)
    end

    it 'recalculates members average completion score' do
      expect(group).to receive(:update_members_completion_score!)
      described_class.perform_now(group)
    end

    context 'with group with nil parent' do
      before { group.parent = nil }

      it 'does not create new job for parent' do
        expect(described_class).not_to receive(:perform_later).with(parent)
        described_class.perform_now(group)
      end
    end

    context 'with group with a parent' do
      it 'creates new job to update parent' do
        expect(described_class).to receive(:perform_later).with(parent)
        described_class.perform_now(group)
      end
    end
  end
end
