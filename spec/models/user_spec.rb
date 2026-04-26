require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { described_class.new(email_address: 'user@example.com', password: 'password123', password_confirmation: 'password123') }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'is invalid without an email address' do
      user.email_address = nil
      expect(user).not_to be_valid
    end

    it 'is invalid with a duplicate email address' do
      user.save!
      duplicate = described_class.new(email_address: 'user@example.com', password: 'password123')
      expect(duplicate).not_to be_valid
    end

    it 'is invalid without a password on create' do
      user.password = nil
      user.password_confirmation = nil
      expect(user).not_to be_valid
    end

    it 'is invalid when password exceeds 72 bytes' do
      user.password = 'a' * 73
      expect(user).not_to be_valid
    end
  end

  describe 'email normalization' do
    it 'strips whitespace from email address' do
      user.email_address = '  user@example.com  '
      user.save!
      expect(user.email_address).to eq('user@example.com')
    end

    it 'downcases email address' do
      user.email_address = 'User@EXAMPLE.COM'
      user.save!
      expect(user.email_address).to eq('user@example.com')
    end
  end

  describe 'associations' do
    it 'has many sessions' do
      expect(described_class.reflect_on_association(:sessions).macro).to eq(:has_many)
    end

    it 'destroys associated sessions on user destroy' do
      user.save!
      user.sessions.create!(user_agent: 'TestBrowser', ip_address: '127.0.0.1')
      expect { user.destroy }.to change(Session, :count).by(-1)
    end
  end

  describe '.authenticate_by' do
    before { user.save! }

    it 'returns the user when credentials are correct' do
      expect(described_class.authenticate_by(email_address: 'user@example.com', password: 'password123')).to eq(user)
    end

    it 'returns nil when the password is wrong' do
      expect(described_class.authenticate_by(email_address: 'user@example.com', password: 'wrongpassword')).to be_nil
    end

    it 'returns nil when the email is not found' do
      expect(described_class.authenticate_by(email_address: 'nobody@example.com', password: 'password123')).to be_nil
    end
  end
end
