# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PersonDestroyer, type: :service do
  subject { described_class.new(person) }

  let(:person) do
    double(
      'Person',
      destroy!: true,
      new_record?: false,
      notify_of_change?: false,
      email: 'user@example.com',
      name: 'Foo Bar'
    )
  end

  describe 'initialize' do
    it 'raises an exception if person is a new record' do
      allow(person).to receive(:new_record?).and_return(true)
      expect { subject }.to raise_error(/Cannot destroy a new Person record/)
    end
  end

  describe 'destroy!' do
    let(:notify) { instance_double(GovukNotify, deleted_profile: true) }

    before do
      allow(GovukNotify).to receive(:new).and_return(notify)
    end

    it 'destroys the person record' do
      expect(person).to receive(:destroy!)
      subject.destroy!
    end

    it 'sends a deleted profile email if required' do
      allow(person)
        .to receive(:notify_of_change?)
        .with(current_user)
        .and_return(true)
      expect(notify).to receive(:deleted_profile).with('user@example.com', recipient_name: 'Foo Bar')
      subject.destroy!
    end
  end
end
