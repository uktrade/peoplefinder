# frozen_string_literal: true

require 'rails_helper'

class ImageDimensionsTestModel
  include ActiveModel::Model

  attr_accessor :image, :upload_dimensions

  validates :image, image_dimensions: { min_width: 648, min_height: 648, max_width: 8192, max_height: 8192 }
end

RSpec.describe ImageDimensionsValidator, type: :validator do
  subject { ImageDimensionsTestModel.new(image: sample_image) }

  before do
    allow(subject).to receive(:upload_dimensions).and_return(width: width, height: height)
  end

  context 'image with dimensions less than minimum' do
    let(:width) { 649 }
    let(:height) { 647 }

    it { is_expected.to be_invalid }

    it 'assigns a default error message' do
      expect { subject.valid? }.to change(subject.errors, :count).by 1
      subject.valid?
      expect(subject.errors.full_messages).to include(/is not big enough. Your image was 649 by 647 pixels, but it needs to be at least 648 by 648 pixels/)
    end
  end

  context 'image with dimensions equal to the minimum' do
    let(:width) { 648 }
    let(:height) { 648 }

    it { is_expected.to be_valid }
  end

  context 'image with dimensions over the minimum' do
    let(:width) { 649 }
    let(:height) { 649 }

    it { is_expected.to be_valid }
  end

  context 'image with dimensions more than the maximum' do
    let(:width) { 8193 }
    let(:height) { 8192 }

    it { is_expected.to be_invalid }

    it 'assigns a default error message' do
      expect { subject.valid? }.to change(subject.errors, :count).by 1
      subject.valid?
      expect(subject.errors.full_messages).to include(/is too big. Your image was 8193 by 8192 pixels, but it needs to be no more than 8192 by 8192 pixels/)
    end
  end

  context 'image with dimensions equal to the maximum' do
    let(:width) { 8192 }
    let(:height) { 8192 }

    it { is_expected.to be_valid }
  end
end
