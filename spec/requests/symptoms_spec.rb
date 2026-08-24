require 'rails_helper'

RSpec.describe 'Symptoms', type: :request do
  let(:user)    { create(:user) }
  let(:patient) { create(:patient, user: user) }

  def sign_in(usr = user)
    post session_path, params: { email_address: usr.email_address, password: 'password123' }
  end

  describe 'GET /patients/:patient_id/symptoms' do
    before { sign_in }

    it "returns 200 for the patient's own calendar" do
      get patient_symptoms_path(patient)
      expect(response).to have_http_status(:ok)
    end

    it 'returns 404 when the patient belongs to another user' do
      other_patient = create(:patient, user: create(:user))
      get patient_symptoms_path(other_patient)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /patients/:patient_id/symptoms/day/:date' do
    before { sign_in }

    it 'returns 200 and lists symptoms reported on that day', :aggregate_failures do
      symptom = create(:symptom, patient: patient, name: 'Headache')
      create(:symptom_entry, symptom: symptom, date: Date.current)

      get day_patient_symptoms_path(patient, date: Date.current.iso8601)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Headache')
    end

    it 'returns 404 when the patient belongs to another user' do
      other_patient = create(:patient, user: create(:user))
      get day_patient_symptoms_path(other_patient, date: Date.current.iso8601)
      expect(response).to have_http_status(:not_found)
    end
  end
end
