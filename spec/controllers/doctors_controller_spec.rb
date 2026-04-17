require 'rails_helper'

RSpec.describe DoctorsController, type: :controller do
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
    { name: nil } # Invalid because name is required
  }

  let(:doctor) { Doctor.create! valid_attributes }

  # Stub authentication for all examples in this group so that
  # DoctorsController tests are not blocked by the auth before_action.
  before do
    allow(controller).to receive(:require_authentication)
  end

  describe 'unauthenticated access' do
    before { allow(controller).to receive(:require_authentication).and_call_original }

    it 'redirects to sign-in when not authenticated' do
      get :index
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns all doctors as @doctors' do
      doctor # Ensure at least one doctor exists
      get :index
      expect(assigns(:doctors)).to eq([ doctor ])
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: doctor.to_param }
      expect(response).to be_successful
    end

    it 'assigns the requested doctor as @doctor' do
      get :show, params: { id: doctor.to_param }
      expect(assigns(:doctor)).to eq(doctor)
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new doctor as @doctor' do
      get :new
      expect(assigns(:doctor)).to be_a_new(Doctor)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Doctor' do
        expect {
          post :create, params: { doctor: valid_attributes }
        }.to change(Doctor, :count).by(1)
      end

      it 'assigns a newly created doctor as @doctor' do
        post :create, params: { doctor: valid_attributes }
        expect(assigns(:doctor)).to be_a(Doctor)
        expect(assigns(:doctor)).to be_persisted
      end

      it 'redirects to the created doctor' do
        post :create, params: { doctor: valid_attributes }
        expect(response).to redirect_to(Doctor.last)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Doctor' do
        expect {
          post :create, params: { doctor: invalid_attributes }
        }.to change(Doctor, :count).by(0)
      end

      it 'assigns a newly created but unsaved doctor as @doctor' do
        post :create, params: { doctor: invalid_attributes }
        expect(assigns(:doctor)).to be_a_new(Doctor)
      end

      it 're-renders the new template' do
        post :create, params: { doctor: invalid_attributes }
        expect(response).to render_template(:new)
      end

      it 'returns unprocessable_entity status' do
        post :create, params: { doctor: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      get :edit, params: { id: doctor.to_param }
      expect(response).to be_successful
    end

    it 'assigns the requested doctor as @doctor' do
      get :edit, params: { id: doctor.to_param }
      expect(assigns(:doctor)).to eq(doctor)
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        { name: 'Dr. Jane Smith' }
      }

      it 'updates the requested doctor' do
        put :update, params: { id: doctor.to_param, doctor: new_attributes }
        doctor.reload
        expect(doctor.name).to eq('Dr. Jane Smith')
      end

      it 'assigns the requested doctor as @doctor' do
        put :update, params: { id: doctor.to_param, doctor: valid_attributes }
        expect(assigns(:doctor)).to eq(doctor)
      end

      it 'redirects to the doctor' do
        put :update, params: { id: doctor.to_param, doctor: valid_attributes }
        expect(response).to redirect_to(doctor)
      end
    end

    context 'with invalid params' do
      it 'does not update the doctor' do
        original_name = doctor.name
        put :update, params: { id: doctor.to_param, doctor: invalid_attributes }
        doctor.reload
        expect(doctor.name).to eq(original_name)
      end

      it 'assigns the doctor as @doctor' do
        put :update, params: { id: doctor.to_param, doctor: invalid_attributes }
        expect(assigns(:doctor)).to eq(doctor)
      end

      it 're-renders the edit template' do
        put :update, params: { id: doctor.to_param, doctor: invalid_attributes }
        expect(response).to render_template(:edit)
      end

      it 'returns unprocessable_entity status' do
        put :update, params: { id: doctor.to_param, doctor: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
