require 'rails_helper'

RSpec.describe MedicationsController, type: :controller do
  let(:user) { create(:user) }
  let(:session_record) { create(:session, user: user) }
  let(:patient) { create(:patient, user: user) }

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

    it 'assigns active and past medications', :aggregate_failures do
      active = create(:medication, :active, patient: patient)
      past = create(:medication, :past, patient: patient)
      get :index, params: { patient_id: patient.to_param }
      expect(assigns(:active_medications)).to include(active)
      expect(assigns(:past_medications)).to include(past)
    end
  end

  describe 'GET #index sorting active medications' do
    let!(:med_a) { create(:medication, patient: patient, name: 'Aspirin', dosage: '100mg', date_started: '2026-01-01') }
    let!(:med_b) { create(:medication, patient: patient, name: 'Zyrtec', dosage: '10mg', date_started: '2026-03-01') }

    it 'defaults to sorting by name ascending', :aggregate_failures do
      get :index, params: { patient_id: patient.to_param }
      expect(assigns(:active_sort)).to eq('name')
      expect(assigns(:active_direction)).to eq('asc')
      expect(assigns(:active_medications).to_a).to eq([ med_a, med_b ])
    end

    it 'sorts by name descending' do
      get :index, params: { patient_id: patient.to_param, active_sort: 'name', active_direction: 'desc' }
      expect(assigns(:active_medications).to_a).to eq([ med_b, med_a ])
    end

    it 'sorts by dosage ascending' do
      get :index, params: { patient_id: patient.to_param, active_sort: 'dosage', active_direction: 'asc' }
      expect(assigns(:active_medications).to_a).to eq([ med_a, med_b ])
    end

    it 'sorts by date_started ascending' do
      get :index, params: { patient_id: patient.to_param, active_sort: 'date_started', active_direction: 'asc' }
      expect(assigns(:active_medications).to_a).to eq([ med_a, med_b ])
    end

    it 'sorts by date_started descending' do
      get :index, params: { patient_id: patient.to_param, active_sort: 'date_started', active_direction: 'desc' }
      expect(assigns(:active_medications).to_a).to eq([ med_b, med_a ])
    end

    it 'ignores an invalid sort column and falls back to name' do
      get :index, params: { patient_id: patient.to_param, active_sort: 'evil; DROP TABLE medications;--' }
      expect(assigns(:active_sort)).to eq('name')
    end

    it 'ignores an invalid direction and falls back to asc' do
      get :index, params: { patient_id: patient.to_param, active_direction: 'sideways' }
      expect(assigns(:active_direction)).to eq('asc')
    end

    it 'sorts active medications by doctor name ascending' do
      doctor_a = create(:doctor, patient: patient, name: 'Dr. Adams')
      doctor_z = create(:doctor, patient: patient, name: 'Dr. Zane')
      med_z = create(:medication, patient: patient, name: 'Aspirin', doctor: doctor_z)
      med_a = create(:medication, patient: patient, name: 'Zyrtec', doctor: doctor_a)
      get :index, params: { patient_id: patient.to_param, active_sort: 'doctor_name', active_direction: 'asc' }
      result = assigns(:active_medications).to_a
      expect(result.index(med_a)).to be < result.index(med_z)
    end
  end

  describe 'GET #index sorting past medications' do
    let!(:past_x) { create(:medication, :past, patient: patient, name: 'Prednisone', date_started: '2025-06-01', date_stopped: '2025-12-01') }
    let!(:past_y) { create(:medication, :past, patient: patient, name: 'Amoxicillin', date_started: '2025-01-01', date_stopped: '2025-03-01') }

    it 'defaults to sorting by name ascending', :aggregate_failures do
      get :index, params: { patient_id: patient.to_param }
      expect(assigns(:past_sort)).to eq('name')
      expect(assigns(:past_direction)).to eq('asc')
      expect(assigns(:past_medications).to_a).to eq([ past_y, past_x ])
    end

    it 'sorts by name descending' do
      get :index, params: { patient_id: patient.to_param, past_sort: 'name', past_direction: 'desc' }
      expect(assigns(:past_medications).to_a).to eq([ past_x, past_y ])
    end

    it 'sorts by date_stopped ascending' do
      get :index, params: { patient_id: patient.to_param, past_sort: 'date_stopped', past_direction: 'asc' }
      expect(assigns(:past_medications).to_a).to eq([ past_y, past_x ])
    end

    it 'sorts by date_stopped descending' do
      get :index, params: { patient_id: patient.to_param, past_sort: 'date_stopped', past_direction: 'desc' }
      expect(assigns(:past_medications).to_a).to eq([ past_x, past_y ])
    end

    it 'ignores an invalid sort column and falls back to name' do
      get :index, params: { patient_id: patient.to_param, past_sort: 'injected_column' }
      expect(assigns(:past_sort)).to eq('name')
    end

    it 'sorts past medications by doctor name ascending' do
      doctor_a = create(:doctor, patient: patient, name: 'Dr. Adams')
      doctor_z = create(:doctor, patient: patient, name: 'Dr. Zane')
      past_z = create(:medication, :past, patient: patient, name: 'Aspirin', doctor: doctor_z)
      past_a = create(:medication, :past, patient: patient, name: 'Zyrtec', doctor: doctor_a)
      get :index, params: { patient_id: patient.to_param, past_sort: 'doctor_name', past_direction: 'asc' }
      result = assigns(:past_medications).to_a
      expect(result.index(past_a)).to be < result.index(past_z)
    end
  end

  describe 'GET #index sorting independently' do
    let!(:active_pair) do
      [
        create(:medication, patient: patient, name: 'Aspirin'),
        create(:medication, patient: patient, name: 'Zyrtec')
      ]
    end
    let!(:past_pair) do
      [
        create(:medication, :past, patient: patient, name: 'Amoxicillin', date_stopped: '2025-03-01'),
        create(:medication, :past, patient: patient, name: 'Prednisone', date_stopped: '2025-12-01')
      ]
    end

    before do
      get :index, params: {
        patient_id: patient.to_param,
        active_sort: 'name', active_direction: 'desc',
        past_sort: 'name', past_direction: 'asc'
      }
    end

    it 'applies active sort independently of past sort' do
      expect(assigns(:active_medications).to_a).to eq(active_pair.reverse)
    end

    it 'applies past sort independently of active sort' do
      expect(assigns(:past_medications).to_a).to eq(past_pair)
    end
  end

  describe 'GET #show' do
    let(:medication) { create(:medication, patient: patient) }

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
    let(:medication) { create(:medication, patient: patient) }

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
    let(:valid_attributes) { attributes_for(:medication) }

    context 'with valid params' do
      it 'creates a new Medication' do
        expect {
          post :create, params: { patient_id: patient.to_param, medication: valid_attributes }
        }.to change(Medication, :count).by(1)
      end

      it 'assigns a newly created medication as @medication', :aggregate_failures do
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
      let(:invalid_attributes) { { name: nil } }

      it 'does not create a new Medication' do
        expect {
          post :create, params: { patient_id: patient.to_param, medication: invalid_attributes }
        }.not_to change(Medication, :count)
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
    let(:medication) { create(:medication, patient: patient) }

    context 'with valid params' do
      let(:new_attributes) { { name: 'Metformin XR' } }

      it 'updates the requested medication' do
        put :update, params: { patient_id: patient.to_param, id: medication.to_param, medication: new_attributes }
        medication.reload
        expect(medication.name).to eq('Metformin XR')
      end

      it 'assigns the requested medication as @medication' do
        put :update, params: { patient_id: patient.to_param, id: medication.to_param, medication: attributes_for(:medication) }
        expect(assigns(:medication)).to eq(medication)
      end

      it 'redirects to the medication' do
        put :update, params: { patient_id: patient.to_param, id: medication.to_param, medication: attributes_for(:medication) }
        expect(response).to redirect_to(patient_medication_path(patient, medication))
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) { { name: nil } }

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
    let(:medication) { create(:medication, patient: patient) }

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
