require 'rails_helper'

RSpec.describe PatientsController, type: :controller do
  let(:user) { User.create!(email_address: 'user@example.com', password: 'password123') }
  let(:session_record) { user.sessions.create!(user_agent: 'TestBrowser', ip_address: '127.0.0.1') }

  let(:valid_attributes) { { name: 'John Smith' } }
  let(:invalid_attributes) { { name: nil } }

  let(:patient) { user.patients.create!(name: 'Jane Doe') }

  before do
    allow(controller).to receive(:resume_session) do
      Current.session = session_record
    end
  end

  describe 'unauthenticated access' do
    before { allow(controller).to receive(:resume_session).and_call_original }

    it 'redirects to sign-in when not authenticated' do
      get :index
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it "assigns the current user's patients as @patients" do
      patient
      get :index
      expect(assigns(:patients)).to eq([ patient ])
    end

    it 'does not include patients belonging to other users' do
      other_user = User.create!(email_address: 'other@example.com', password: 'password123')
      other_user.patients.create!(name: 'Other Patient')
      patient
      get :index
      expect(assigns(:patients)).to eq([ patient ])
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: patient.to_param }
      expect(response).to be_successful
    end

    it 'assigns the requested patient as @patient' do
      get :show, params: { id: patient.to_param }
      expect(assigns(:patient)).to eq(patient)
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new patient as @patient' do
      get :new
      expect(assigns(:patient)).to be_a_new(Patient)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Patient scoped to the current user' do
        expect {
          post :create, params: { patient: valid_attributes }
        }.to change(Patient, :count).by(1)
      end

      it 'associates the new patient with the current user' do
        post :create, params: { patient: valid_attributes }
        expect(Patient.last.user).to eq(user)
      end

      it 'redirects to the created patient' do
        post :create, params: { patient: valid_attributes }
        expect(response).to redirect_to(Patient.last)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Patient' do
        expect {
          post :create, params: { patient: invalid_attributes }
        }.not_to change(Patient, :count)
      end

      it 'assigns a newly created but unsaved patient as @patient' do
        post :create, params: { patient: invalid_attributes }
        expect(assigns(:patient)).to be_a_new(Patient)
      end

      it 're-renders the new template' do
        post :create, params: { patient: invalid_attributes }
        expect(response).to render_template(:new)
      end

      it 'returns unprocessable_entity status' do
        post :create, params: { patient: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      get :edit, params: { id: patient.to_param }
      expect(response).to be_successful
    end

    it 'assigns the requested patient as @patient' do
      get :edit, params: { id: patient.to_param }
      expect(assigns(:patient)).to eq(patient)
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { name: 'Updated Name' } }

      it 'updates the requested patient' do
        put :update, params: { id: patient.to_param, patient: new_attributes }
        patient.reload
        expect(patient.name).to eq('Updated Name')
      end

      it 'redirects to the patient' do
        put :update, params: { id: patient.to_param, patient: valid_attributes }
        expect(response).to redirect_to(patient)
      end
    end

    context 'with invalid params' do
      it 'does not update the patient' do
        original_name = patient.name
        put :update, params: { id: patient.to_param, patient: invalid_attributes }
        patient.reload
        expect(patient.name).to eq(original_name)
      end

      it 're-renders the edit template' do
        put :update, params: { id: patient.to_param, patient: invalid_attributes }
        expect(response).to render_template(:edit)
      end

      it 'returns unprocessable_entity status' do
        put :update, params: { id: patient.to_param, patient: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested patient' do
      patient
      expect {
        delete :destroy, params: { id: patient.to_param }
      }.to change(Patient, :count).by(-1)
    end

    it 'redirects to the patients list' do
      delete :destroy, params: { id: patient.to_param }
      expect(response).to redirect_to(patients_path)
    end
  end
end
