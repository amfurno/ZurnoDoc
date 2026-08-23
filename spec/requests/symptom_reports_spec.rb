require 'rails_helper'

RSpec.describe 'SymptomReports', type: :request do
  let(:user)    { create(:user) }
  let(:patient) { create(:patient, user: user) }

  def sign_in(usr = user)
    post session_path, params: { email_address: usr.email_address, password: 'password123' }
  end

  describe 'GET /patients/:patient_id/symptom_report/new' do
    before { sign_in }

    it "returns 200 for the patient's own report form" do
      get new_patient_symptom_report_path(patient)
      expect(response).to have_http_status(:ok)
    end

    it 'returns 404 when the patient belongs to another user' do
      other_patient = create(:patient, user: create(:user))
      get new_patient_symptom_report_path(other_patient)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /patients/:patient_id/symptom_report' do
    before { sign_in }

    let!(:symptom) { create(:symptom, patient: patient, name: 'Headache') }
    let(:report_params) do
      { symptom_report: { date: Date.current.iso8601, symptom_ids: [symptom.id],
                          new_symptoms_text: "Fatigue\nNausea" } }
    end

    it 'creates entries and redirects to the calendar', :aggregate_failures do
      expect do
        post patient_symptom_report_path(patient), params: report_params
      end.to change(SymptomEntry, :count).by(3).and change(Symptom, :count).by(2)
      expect(response).to redirect_to(patient_symptoms_path(patient, start_date: Date.current.beginning_of_month))
    end

    it 're-renders the form with an unprocessable status when the date is invalid' do
      post patient_symptom_report_path(patient), params: {
        symptom_report: { date: '', new_symptoms_text: '' }
      }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
