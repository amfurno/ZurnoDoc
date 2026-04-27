require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  let(:user) { create(:user) }

  # Sign in via the normal login flow so a real signed cookie is issued.
  def sign_in(u = user)
    post session_path, params: { email_address: u.email_address, password: 'password123' }
  end

  describe 'expired session' do
    before { sign_in }

    it 'redirects to login when the session has expired' do
      Session.last.update_columns(expires_at: 1.minute.ago)
      get patients_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'absolute-TTL enforcement' do
    before { sign_in }

    context 'when absolute TTL is reached' do
      it 'destroys the session' do
        session_record = Session.last
        session_record.update_columns(absolute_expires_at: 1.minute.ago, expires_at: 5.minutes.from_now)

        expect { get patients_path }.to change(Session, :count).by(-1)
      end

      it 'redirects to login when absolute TTL is reached' do
        session_record = Session.last
        session_record.update_columns(absolute_expires_at: 1.minute.ago, expires_at: 5.minutes.from_now)
        get patients_path
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'session sliding' do
    before { sign_in }

    it 'pushes expires_at forward by SESSION_LENGTH from the time of the request' do
      travel(30.seconds) do
        get patients_path
        expect(Session.last.expires_at).to eq(Time.current + Session::SESSION_LENGTH)
      end
    end

    it 're-issues the Set-Cookie header with the updated expiry' do
      travel(30.seconds) do
        get patients_path
        expect(response.headers['Set-Cookie']).to be_present
      end
    end
  end
end
