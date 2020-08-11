# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfilePhoto, type: :model do
  subject { create(:profile_photo) }

  it { is_expected.to respond_to :upload_dimensions }
  it { is_expected.to respond_to :crop_x }
  it { is_expected.to respond_to :crop_y }
  it { is_expected.to respond_to :crop_w }
  it { is_expected.to respond_to :crop_h }

  it 'has one person' do
    person_association = described_class.reflect_on_association(:person).macro
    expect(person_association).to be :has_one
  end

  it 'stores upload dimensions' do
    expect(subject.upload_dimensions).to eq width: 648, height: 648
  end

  describe 'validations' do
    subject { build(:profile_photo) }

    context 'file' do
      context 'extension is whitelisted' do
        it do
          subject.image = non_white_list_image
          expect(subject).to be_invalid
        end

        it do
          subject.image = valid_image
          expect(subject).to be_valid
        end
      end
    end

    context 'image dimensions' do
      context 'must be greater than 500x500 pixels' do
        it do
          allow(subject).to receive(:upload_dimensions).and_return(width: 501, height: 499)
          expect(subject).to be_invalid
        end

        it do
          allow(subject).to receive(:upload_dimensions).and_return(width: 500, height: 500)
          expect(subject).to be_valid
        end
      end

      context 'must be less than or equal to 8192x8192 pixels' do
        it do
          allow(subject).to receive(:upload_dimensions).and_return(width: 8193, height: 8192)
          expect(subject).to be_invalid
        end

        it do
          allow(subject).to receive(:upload_dimensions).and_return(width: 8192, height: 8192)
          expect(subject).to be_valid
        end
      end
    end

    context 'saving file' do
      context 'with unwhitelisted extension' do
        subject { build :profile_photo, :invalid_extension }

        it 'raises expected error' do
          expect { subject.save! }.to raise_error ActiveRecord::RecordInvalid, /This file is not an accepted image format. Please choose a JPG or PNG file./
        end
      end

      context 'with too small dimensions' do
        subject { build :profile_photo, :too_small_dimensions }

        it 'raises expected error' do
          expect { subject.save! }.to raise_error ActiveRecord::RecordInvalid, /is not big enough. Your image was 499 by 500 pixels, but it needs to be at least 500 by 500 pixels/
        end
      end

      context 'with too large dimensions' do
        subject { build :profile_photo }

        before do
          allow(subject).to receive(:upload_dimensions).and_return(width: 8192, height: 8193)
        end

        it 'raises expected error' do
          expect { subject.save! }.to raise_error ActiveRecord::RecordInvalid, /is too big. Your image was 8192 by 8193 pixels, but it needs to be no more than 8192 by 8192 pixels/
        end
      end
    end
  end
end
