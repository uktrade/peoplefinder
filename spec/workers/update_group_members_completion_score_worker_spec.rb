# frozen_string_literal: true

require 'rails_helper'

describe UpdateGroupMembersCompletionScoreWorker do
  describe '#perform' do
    context 'when the group exists and does not have a parent' do
      let(:group) { instance_double(Group, update_members_completion_score!: true, parent: nil) }

      before do
        allow(Group).to receive(:find).with(7).and_return(group)
        allow(described_class).to receive(:perform_async).and_return(true)
        subject.perform(7)
      end

      it 'updates the members completion score on the group' do
        expect(group).to have_received(:update_members_completion_score!)
      end

      it 'does not enqueue another worker' do
        expect(described_class).not_to have_received(:perform_async)
      end
    end

    context 'when the group exists and has a parent' do
      let(:parent_group) { instance_double(Group, id: 42) }
      let(:group) { instance_double(Group, update_members_completion_score!: true, parent: parent_group) }

      before do
        allow(Group).to receive(:find).with(7).and_return(group)
        allow(described_class).to receive(:perform_async).and_return(true)
        subject.perform(7)
      end

      it 'updates the members completion score on the group' do
        expect(group).to have_received(:update_members_completion_score!)
      end

      it 'enqueues a worker for the parent too' do
        expect(described_class).to have_received(:perform_async).with(42)
      end
    end

    context 'when the does not exist' do
      let(:group) { nil }

      before do
        allow(Group).to receive(:find).with(7).and_raise(ActiveRecord::RecordNotFound)
        allow(described_class).to receive(:perform_async).and_return(true)
      end

      it 'does not fail' do
        expect { subject.perform(7) }.not_to raise_error
      end
    end
  end
end
