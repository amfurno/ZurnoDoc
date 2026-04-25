require 'rails_helper'

RSpec.describe Session, type: :model do
  subject(:session) do
    Session.new(user: user, user_agent: 'TestBrowser', ip_address: '127.0.0.1')
  end

  let(:user) { User.create!(email_address: 'user@example.com', password: 'password123') }


  describe 'associations' do
    it 'belongs to a user' do
      expect(Session.reflect_on_association(:user).macro).to eq(:belongs_to)
    end
  end

  describe 'validations' do
    it 'is valid with a user' do
      expect(session).to be_valid
    end

    it 'is invalid without a user' do
      session.user = nil
      expect(session).not_to be_valid
    end
  end
end
