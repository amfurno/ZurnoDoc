require 'rails_helper'

RSpec.describe 'Navbar', type: :request do
  let(:user) { create(:user) }

  def sign_in
    post session_path, params: { email_address: user.email_address, password: 'password123' }
  end

  shared_examples 'a theme-aware navbar' do
    it 'sets the navbar Stimulus controller' do
      expect(response.body).to include('data-controller="navbar"')
    end

    it 'does not apply the hardcoded is-light modifier' do
      expect(response.body).not_to match(/class="navbar[^"]*is-light/)
    end

    it 'renders the navbar-menu with a Stimulus target' do
      expect(response.body).to include('data-navbar-target="menu"')
    end
  end

  shared_examples 'a navbar with a burger menu' do
    it 'renders the navbar-burger' do
      expect(response.body).to include('navbar-burger')
    end

    it 'wires the burger click action to the Stimulus toggle' do
      expect(response.body).to include('data-action="click->navbar#toggle"')
    end

    it 'renders the burger with a Stimulus target' do
      expect(response.body).to include('data-navbar-target="burger"')
    end
  end

  describe 'unauthenticated layout' do
    context 'when visiting a page other than sign-in' do
      before { get new_user_path }

      it_behaves_like 'a theme-aware navbar'
      it_behaves_like 'a navbar with a burger menu'

      it 'does not show the sign-out button' do
        expect(response.body).not_to include('Sign Out')
      end
    end

    context 'when on the sign-in page' do
      before { get login_path }

      it_behaves_like 'a theme-aware navbar'

      it 'does not render the burger menu' do
        expect(response.body).not_to include('navbar-burger')
      end

      it 'shows the sign-up link' do
        expect(response.body).to include('Sign Up')
      end
    end
  end

  describe 'authenticated layout' do
    let!(:patient) { create(:patient, user: user) }

    before do
      sign_in
      get patients_path
    end

    it_behaves_like 'a theme-aware navbar'
    it_behaves_like 'a navbar with a burger menu'

    it 'shows the sign-out button' do
      expect(response.body).to include('Sign Out')
    end

    it 'shows the Patients nav link' do
      expect(response.body).to include(patients_path)
    end

    it 'does not show the Doctors nav link when no patient is selected' do
      expect(response.body).not_to include(patient_doctors_path(patient))
    end

    it 'does not show the Medications nav link when no patient is selected' do
      expect(response.body).not_to include(patient_medications_path(patient))
    end
  end

  describe 'patient nav links' do
    let(:patient) { create(:patient, user: user) }

    context 'when visiting a patient page for the first time (no prior session cookie)' do
      before do
        sign_in
        get patient_path(patient)
      end

      it 'shows the patient name in the navbar immediately' do
        expect(response.body).to include(patient.name)
      end

      it 'shows the Doctors nav link immediately' do
        expect(response.body).to include(patient_doctors_path(patient))
      end

      it 'shows the Medications nav link immediately' do
        expect(response.body).to include(patient_medications_path(patient))
      end
    end

    context 'when revisiting after a session has been established' do
      before do
        sign_in
        get patient_path(patient) # sets session[:current_patient_id]
        get patients_path # next request loads Current.patient from session
      end

      it 'shows the patient name in the navbar' do
        expect(response.body).to include(patient.name)
      end

      it 'links the patient name to their show page' do
        expect(response.body).to include(patient_path(patient))
      end

      it 'shows the Doctors nav link for the selected patient' do
        expect(response.body).to include(patient_doctors_path(patient))
      end

      it 'shows the Medications nav link for the selected patient' do
        expect(response.body).to include(patient_medications_path(patient))
      end
    end
  end

  describe 'session tracking' do
    let(:patient) { create(:patient, user: user) }

    before { sign_in }

    it 'sets session[:current_patient_id] when visiting a patient show page' do
      get patient_path(patient)
      expect(session[:current_patient_id]).to eq(patient.id)
    end

    it 'sets session[:current_patient_id] when visiting a nested doctors route' do
      get patient_doctors_path(patient)
      expect(session[:current_patient_id]).to eq(patient.id)
    end

    it 'sets session[:current_patient_id] when visiting a nested medications route' do
      get patient_medications_path(patient)
      expect(session[:current_patient_id]).to eq(patient.id)
    end

    context 'when the session patient has been deleted' do
      before do
        get patient_path(patient) # sets session
        patient.destroy
      end

      it 'clears the stale session key' do
        get patients_path
        expect(session[:current_patient_id]).to be_nil
      end

      it 'does not show the Doctors nav link' do
        get patients_path
        expect(response.body).not_to include(patient_doctors_path(patient))
      end

      it 'does not show the Medications nav link' do
        get patients_path
        expect(response.body).not_to include(patient_medications_path(patient))
      end
    end
  end
end
