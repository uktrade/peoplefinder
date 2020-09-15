# frozen_string_literal: true

require 'rails_helper'

describe HrDataRow do
  subject { described_class.new(email: email, grade: grade) }

  let(:email) { 'gov@example.com' }
  let(:grade) { 'SCS4 Level' }

  describe '.from_csv_row' do
    subject { described_class.from_csv_row(row) }

    let(:row) { %w[4321234 Foo Bar Intern foo@example.com Domestic] }

    it 'has the expected attributes' do
      expect(subject.email).to eq('foo@example.com')
      expect(subject.grade).to eq('Intern')
    end
  end

  describe '#mapped_grade' do
    it 'returns an appropriate grade mapping' do
      expect(subject.mapped_grade).to eq(:scs_4)
    end
  end

  describe 'validation' do
    context 'email' do
      context 'when missing' do
        let(:email) { '' }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors).to include(:email)
        end
      end

      context 'when incorrect' do
        let(:email) { 'fsuidHSIEurhgloiehfjieo876' }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors).to include(:email)
        end
      end

      context 'when unsanitized' do
        let(:email) { '  Foo@EXAMPLE.com   ' }

        it 'is sanitized and valid after validation' do
          expect(subject).to be_valid
          expect(subject.email).to eq('foo@example.com')
        end
      end
    end

    context 'grade' do
      context 'when missing' do
        let(:grade) { '' }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors).to include(:grade)
        end
      end

      context 'when incorrect' do
        let(:grade) { 'Grade 123' }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors).to include(:grade)
        end
      end

      context 'when unspecified' do
        let(:grade) { 'unspecified' }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'when containing Level' do
        let(:grade) { 'EO Level' }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end
    end
  end
end
