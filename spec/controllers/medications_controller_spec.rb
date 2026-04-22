require 'rails_helper'

RSpec.describe MedicationsController, type: :controller do
  let(:user) { User.create!(email_address: 'user@example.com', password: 'password123') }
  let(:session_record) { user.sessions.create!(user_agent: 'TestBrowser', ip_address: '127.0.0.1') }
  let(:patient) { user.patients.create!(name: 'Jane Doe') }

  let(:valid_attributes) {
    {
      name: 'Metformin',
      drug_class: 'Biguanide',
      dosage: '500mg',
      date_started: '2026-01-01',
      notes: 'Take with food',
      side_effects: 'Nausea'
    }
  }

  let(:invalid_attributes) {
    { name: nil }
  }

  let(:medication) { patient.medications.create! valid_attributes }

  before do
    allow(controller).to receive(:resume_session) do
      Current.session = session_record
    end
  end

  describe 'unauthenticated access' do
    before { allow(controller).to receive(:resume_session).and_call_original }

    it 'redirects to sign-in when not authenticated' do
      get :index, params: { patient_id: patient.to_param }
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: { patient_id: patient.to_param }
      expect(response).to be_successful
    end

    it 'assigns active and past medications' do
      active = patient.medications.create!(valid_attributes)
      past = patient.medications.create!(valid_attributes.merge(date_stopped: '2026-02-01'))
      get :index, params: { patient_id: patient.to_param }
      expect(assigns(:active_medications)).to include(active)
      expect(assigns(:past_medications)).to include(past)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { patient_id: patient.to_param, id: medication.to_param }
      expect(response).to be_successful
    end

    it 'assigns the requested medication as @medication' do
      get :show, params: { patient_id: patient.to_param, id: medication.to_param }
      expect(assigns(:medication)).to eq(medication)
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: { patient_id: patient.to_param }
      expect(response).to be_successful
    end

    it 'assigns a new medication as @medication' do
      get :new, params: { patient_id: patient.to_param }
      expect(assigns(:medication)).to be_a_new(Medication)
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      get :edit, params: { patient_id: patient.to_param, id: medication.to_param }
      expect(response).to be_successful
    end

    it 'assigns the requested medication as @medication' do
      get :edit, params: { patient_id: patient.to_param, id: medication.to_param }
      expect(assigns(:medication)).to eq(medication)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Medication' do
        expect {
          post :create, params: { patient_id: patient.to_param, medication: valid_attributes }
        }.to change(Medication, :count).by(1)
      end

      it 'assigns a newly created medication as @medication' do
        post :create, params: { patient_id: patient.to_param, medication: valid_attributes }
        expect(assigns(:medication)).to be_a(Medication)
        expect(assigns(:medication)).to be_persisted
      end

      it 'associates the medication with the patient' do
        post :create, params: { patient_id: patient.to_param, medication: valid_attributes }
        expect(Medication.last.patient).to eq(patient)
      end

      it 'redirects to the created medication' do
        post :create, params: { patient_id: patient.to_param, medication: valid_attributes }
        expect(response).to redirect_to(patient_medication_path(patient, Medication.last))
      end
    end

    context 'with invalid params' do
      it 'does not create a new Medication' do
        expect {
          post :create, params: { patient_id: patient.to_param, medication: invalid_attributes }
        }.to change(Medication, :count).by(0)
      end

      it 'assigns a newly created but unsaved medication as @medication' do
        post :create, params: { patient_id: patient.to_param, medication: invalid_attributes }
        expect(assigns(:medication)).to be_a_new(Medication)
      end

      it 're-renders the new template' do
        post :create, params: { patient_id: patient.to_param, medication: invalid_attributes }
        expect(response).to render_template(:new)
      end

      it 'returns unprocessable_content status' do
        post :create, params: { patient_id: patient.to_param, medication: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { name: 'Metformin XR' } }

      it 'updates the requested medication' do
        put :update, params: { patient_id: patient.to_param, id: medication.to_param, medication: new_attributes }
        medication.reload
        expect(medication.name).to eq('Metformin XR')
      end

      it 'assigns the requested medication as @medication' do
        put :update, params: { patient_id: patient.to_param, id: medication.to_param, medication: valid_attributes }
        expect(assigns(:medication)).to eq(medication)
      end

      it 'redirects to the medication' do
        put :update, params: { patient_id: patient.to_param, id: medication.to_param, medication: valid_attributes }
        expect(response).to redirect_to(patient_medication_path(patient, medication))
      end
    end

    context 'with invalid params' do
      it 'does not update the medication' do
        original_name = medication.name
        put :update, params: { patient_id: patient.to_param, id: medication.to_param, medication: invalid_attributes }
        medication.reload
        expect(medication.name).to eq(original_name)
      end

      it 'assigns the medication as @medication' do
        put :update, params: { patient_id: patient.to_param, id: medication.to_param, medication: invalid_attributes }
        expect(assigns(:medication)).to eq(medication)
      end

      it 're-renders the edit template' do
        put :update, params: { patient_id: patient.to_param, id: medication.to_param, medication: invalid_attributes }
        expect(response).to render_template(:edit)
      end

      it 'returns unprocessable_content status' do
        put :update, params: { patient_id: patient.to_param, id: medication.to_param, medication: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested medication' do
      medication
      expect {
        delete :destroy, params: { patient_id: patient.to_param, id: medication.to_param }
      }.to change(Medication, :count).by(-1)
    end

    it 'redirects to the medications list' do
      delete :destroy, params: { patient_id: patient.to_param, id: medication.to_param }
      expect(response).to redirect_to(patient_medications_path(patient))
    end
  end
end
