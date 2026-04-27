require 'rails_helper'

RSpec.describe Session, type: :model do
  subject(:session) do
    described_class.new(user: user, user_agent: 'TestBrowser', ip_address: '127.0.0.1')
  end

  let(:frozen_time) { Time.zone.parse('2026-01-01 12:00:00') }
  let(:user) { User.create!(email_address: 'user@example.com', password: 'password123') }

  around { |example| travel_to(frozen_time) { example.run } }

  describe 'associations' do
    it 'belongs to a user' do
      expect(described_class.reflect_on_association(:user).macro).to eq(:belongs_to)
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

  describe 'defaults' do
    it 'sets expires_at to SESSION_LENGTH from now on create' do
      session.save!
      expect(session.expires_at).to eq(frozen_time + Session::SESSION_LENGTH)
    end

    it 'sets absolute_expires_at to ABSOLUTE_TTL from now on create' do
      session.save!
      expect(session.absolute_expires_at).to eq(frozen_time + Session::ABSOLUTE_TTL)
    end
  end

  describe '.active scope' do
    let!(:active_session)   { create(:session, user: user) }
    let!(:expired_session)  { create(:session, :expired, user: user) }

    it 'includes sessions with expires_at in the future' do
      expect(described_class.active).to include(active_session)
    end

    it 'excludes sessions with expires_at in the past' do
      expect(described_class.active).not_to include(expired_session)
    end
  end

  describe '#expired?' do
    it 'returns false for an active session' do
      session.save!
      expect(session).not_to be_expired
    end

    it 'returns true when expires_at is in the past' do
      session.save!
      session.update_columns(expires_at: 1.minute.ago)
      expect(session).to be_expired
    end

    it 'returns true when absolute_expires_at is in the past' do
      session.save!
      session.update_columns(absolute_expires_at: 1.minute.ago)
      expect(session).to be_expired
    end
  end

  describe '#slide!' do
    context 'when within absolute TTL' do
      let(:active_session) { create(:session, user: user) }

      it 'pushes expires_at forward by SESSION_LENGTH' do
        active_session.slide!
        expect(active_session.reload.expires_at).to eq(frozen_time + Session::SESSION_LENGTH)
      end

      it 'returns the updated session record' do
        result = active_session.slide!
        expect(result).to be_a(described_class)
      end

      it 'caps expires_at at absolute_expires_at' do
        close_to_absolute = frozen_time + 5.minutes
        active_session.update_columns(absolute_expires_at: close_to_absolute)
        active_session.slide!
        expect(active_session.reload.expires_at).to eq(close_to_absolute)
      end
    end

    context 'when absolute TTL has been reached' do
      let!(:absolute_expired_session) { create(:session, :absolute_expired, user: user) }

      it 'destroys the session' do
        expect { absolute_expired_session.slide! }.to change(described_class, :count).by(-1)
      end

      it 'returns false' do
        expect(absolute_expired_session.slide!).to be(false)
      end
    end
  end
end
