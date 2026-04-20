require 'rails_helper'

RSpec.describe DoctorsController, type: :controller do
  let(:user) { User.create!(email_address: 'user@example.com', password: 'password123') }
  let(:session_record) { user.sessions.create!(user_agent: 'TestBrowser', ip_address: '127.0.0.1') }
  let(:patient) { user.patients.create!(name: 'Jane Doe') }

  let(:valid_attributes) {
    {
      name: 'Dr. John Doe',
      practice: 'Family Practice',
      speciality: 'General Medicine',
      email: 'john.doe@example.com',
      phone_number: '123-456-7890',
      fax_number: '123-456-7891',
      address: '123 Main St, Anytown, USA'
    }
  }

  let(:invalid_attributes) {
    { name: nil }
  }

  let(:doctor) { patient.doctors.create! valid_attributes }

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

    it "assigns the patient's doctors as @doctors" do
      doctor
      get :index, params: { patient_id: patient.to_param }
      expect(assigns(:doctors)).to eq([ doctor ])
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { patient_id: patient.to_param, id: doctor.to_param }
      expect(response).to be_successful
    end

    it 'assigns the requested doctor as @doctor' do
      get :show, params: { patient_id: patient.to_param, id: doctor.to_param }
      expect(assigns(:doctor)).to eq(doctor)
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: { patient_id: patient.to_param }
      expect(response).to be_successful
    end

    it 'assigns a new doctor as @doctor' do
      get :new, params: { patient_id: patient.to_param }
      expect(assigns(:doctor)).to be_a_new(Doctor)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Doctor' do
        expect {
          post :create, params: { patient_id: patient.to_param, doctor: valid_attributes }
        }.to change(Doctor, :count).by(1)
      end

      it 'assigns a newly created doctor as @doctor' do
        post :create, params: { patient_id: patient.to_param, doctor: valid_attributes }
        expect(assigns(:doctor)).to be_a(Doctor)
        expect(assigns(:doctor)).to be_persisted
      end

      it 'associates the doctor with the patient' do
        post :create, params: { patient_id: patient.to_param, doctor: valid_attributes }
        expect(Doctor.last.patient).to eq(patient)
      end

      it 'redirects to the created doctor' do
        post :create, params: { patient_id: patient.to_param, doctor: valid_attributes }
        expect(response).to redirect_to(patient_doctor_path(patient, Doctor.last))
      end
    end

    context 'with invalid params' do
      it 'does not create a new Doctor' do
        expect {
          post :create, params: { patient_id: patient.to_param, doctor: invalid_attributes }
        }.to change(Doctor, :count).by(0)
      end

      it 'assigns a newly created but unsaved doctor as @doctor' do
        post :create, params: { patient_id: patient.to_param, doctor: invalid_attributes }
        expect(assigns(:doctor)).to be_a_new(Doctor)
      end

      it 're-renders the new template' do
        post :create, params: { patient_id: patient.to_param, doctor: invalid_attributes }
        expect(response).to render_template(:new)
      end

      it 'returns unprocessable_entity status' do
        post :create, params: { patient_id: patient.to_param, doctor: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      get :edit, params: { patient_id: patient.to_param, id: doctor.to_param }
      expect(response).to be_successful
    end

    it 'assigns the requested doctor as @doctor' do
      get :edit, params: { patient_id: patient.to_param, id: doctor.to_param }
      expect(assigns(:doctor)).to eq(doctor)
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        { name: 'Dr. Jane Smith' }
      }

      it 'updates the requested doctor' do
        put :update, params: { patient_id: patient.to_param, id: doctor.to_param, doctor: new_attributes }
        doctor.reload
        expect(doctor.name).to eq('Dr. Jane Smith')
      end

      it 'assigns the requested doctor as @doctor' do
        put :update, params: { patient_id: patient.to_param, id: doctor.to_param, doctor: valid_attributes }
        expect(assigns(:doctor)).to eq(doctor)
      end

      it 'redirects to the doctor' do
        put :update, params: { patient_id: patient.to_param, id: doctor.to_param, doctor: valid_attributes }
        expect(response).to redirect_to(patient_doctor_path(patient, doctor))
      end
    end

    context 'with invalid params' do
      it 'does not update the doctor' do
        original_name = doctor.name
        put :update, params: { patient_id: patient.to_param, id: doctor.to_param, doctor: invalid_attributes }
        doctor.reload
        expect(doctor.name).to eq(original_name)
      end

      it 'assigns the doctor as @doctor' do
        put :update, params: { patient_id: patient.to_param, id: doctor.to_param, doctor: invalid_attributes }
        expect(assigns(:doctor)).to eq(doctor)
      end

      it 're-renders the edit template' do
        put :update, params: { patient_id: patient.to_param, id: doctor.to_param, doctor: invalid_attributes }
        expect(response).to render_template(:edit)
      end

      it 'returns unprocessable_entity status' do
        put :update, params: { patient_id: patient.to_param, id: doctor.to_param, doctor: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested doctor' do
      doctor
      expect {
        delete :destroy, params: { patient_id: patient.to_param, id: doctor.to_param }
      }.to change(Doctor, :count).by(-1)
    end

    it 'redirects to the doctors list' do
      delete :destroy, params: { patient_id: patient.to_param, id: doctor.to_param }
      expect(response).to redirect_to(patient_doctors_path(patient))
    end
  end
end
