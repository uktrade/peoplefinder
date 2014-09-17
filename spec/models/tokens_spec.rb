require 'rails_helper'

RSpec.describe Token, type: :model do
  it 'generates a token' do
    token = create(:token)
    expect(token.value).to match(/\A[a-z0-9\-]{36}\z/)
  end

  it 'preserves the same token after persisting' do
    token = create(:token)
    value = token.value
    token.save!
    token.reload
    expect(token.value).to eql(value)
  end

  it 'will be valid with valid email address' do
    token = build(:token)
    expect(token).to be_valid
  end
  it 'will be invalid with invalid email address' do
    token = build(:token, user_email: 'bob')
    expect(token).not_to be_valid
  end
  it 'will be invalid with email address from wrong domain' do
    token = build(:token, user_email: 'bob@example.com')
    expect(token).not_to be_valid
  end
end
