require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) { User.create!(email_address: 'user@example.com', password: 'password123') }

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    before { user } # ensure user record exists before posting

    context 'with valid credentials' do
      it 'starts a new session and redirects to root' do
        post :create, params: { email_address: 'user@example.com', password: 'password123' }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with invalid credentials' do
      it 'redirects back to sign-in with an alert' do
        post :create, params: { email_address: 'user@example.com', password: 'wrongpassword' }
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:session_record) { user.sessions.create!(user_agent: 'TestBrowser', ip_address: '127.0.0.1') }

    before do
      # resume_session is the before_action that sets Current.session;
      # stub it to set Current.session so that terminate_session can destroy it.
      allow(controller).to receive(:resume_session) do
        Current.session = session_record
      end
    end

    it 'destroys the current session and redirects to sign-in' do
      delete :destroy
      expect(response).to redirect_to(login_path)
    end

    it 'removes the session record' do
      session_record # ensure it exists
      expect { delete :destroy }.to change(Session, :count).by(-1)
    end
  end
end
