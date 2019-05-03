# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailValidator, type: :validator do
  class EmailValidatorTestModel
    include ActiveModel::Model

    attr_accessor :email

    validates :email, 'email' => true
  end

  subject { EmailValidatorTestModel.new(email: email) }

  context 'email is a valid email' do
    let(:email) { 'name.surname@valid.gov.uk' }

    it { is_expected.to be_valid }
  end

  context 'email is not a valid e-mail' do
    let(:email) { 'name surname@valid.gov.uk' }

    it { is_expected.not_to be_valid }
  end
end
