require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:valid_attributes) do
    { email_address: 'newuser@example.com', password: 'password123', password_confirmation: 'password123' }
  end

  let(:invalid_attributes) do
    { email_address: '', password: 'password123', password_confirmation: 'password123' }
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new user' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new User' do
        expect {
          post :create, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
      end

      it 'redirects to root after creation' do
        post :create, params: { user: valid_attributes }
        expect(response).to redirect_to(root_path)
      end

      it 'sets a flash notice' do
        post :create, params: { user: valid_attributes }
        expect(flash[:notice]).to be_present
      end

      it 'auto-signs-in the new user by creating a session' do
        expect {
          post :create, params: { user: valid_attributes }
        }.to change(Session, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new User' do
        expect {
          post :create, params: { user: invalid_attributes }
        }.not_to change(User, :count)
      end

      it 're-renders the new template' do
        post :create, params: { user: invalid_attributes }
        expect(response).to render_template(:new)
      end

      it 'returns unprocessable_content status' do
        post :create, params: { user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'assigns the invalid user' do
        post :create, params: { user: invalid_attributes }
        expect(assigns(:user)).to be_a_new(User)
      end
    end
  end
end
