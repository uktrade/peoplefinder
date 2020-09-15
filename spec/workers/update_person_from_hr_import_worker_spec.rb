# frozen_string_literal: true

require 'rails_helper'

describe UpdatePersonFromHrImportWorker do
  let(:input) { %w[some hr data] }
  let(:logger) { double('logger', info: true) }
  let(:hr_data_row) { instance_double(HrDataRow, invalid?: false, email: 'foo@bar.com', mapped_grade: :scs_4) }

  before do
    allow(Rails).to receive(:logger).and_return(logger)
    allow(HrDataRow).to receive(:from_csv_row).and_return(hr_data_row)
  end

  describe '#perform' do
    context 'when the data is invalid' do
      let(:errors) { double('errors', full_messages: %w[hello world]) }
      let(:hr_data_row) { instance_double(HrDataRow, errors: errors, invalid?: true) }

      it 'logs an error message' do
        expect(logger).to receive(:error).with(a_string_matching(/Could not parse record.*hello, world/))

        subject.perform(input)
      end
    end

    context 'when no matching person is found' do
      it 'logs a warning message' do
        expect(logger).to receive(:warn).with(a_string_matching(/Could not match record/))

        subject.perform(input)
      end
    end

    context 'when a match is found but the grade has not changed' do
      before do
        create(:person, email: 'foo@bar.com', grade: :scs_4)
      end

      it 'logs an info message' do
        expect(logger).to receive(:info).with(a_string_matching(/Grade for user 'foo@bar.com' has not changed/))

        subject.perform(input)
      end
    end

    context 'when a match is found and the grade has changed' do
      let!(:person) { create(:person, email: 'foo@bar.com', grade: :scs_2) }

      it 'logs an info message' do
        expect(logger).to receive(:info).with(a_string_matching(/Changed grade for user 'foo@bar.com' to scs_4/))

        subject.perform(input)
      end

      it 'updates the grade on the match' do
        subject.perform(input)
        person.reload

        expect(person.grade).to eq('scs_4')
      end

      it 'adds a version with the correct whodunnit' do
        with_versioning do
          subject.perform(input)
        end
        person.reload

        expect(person.versions.last.whodunnit).to eq('HR Data Import')
      end
    end
  end
end
