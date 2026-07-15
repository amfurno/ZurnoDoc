require 'rails_helper'

RSpec.describe 'HealthMetrics', type: :request do
  let(:user)    { create(:user) }
  let(:patient) { create(:patient, user: user) }
  let(:metric)  { create(:health_metric, patient: patient) }

  def sign_in(usr = user)
    post session_path, params: { email_address: usr.email_address, password: 'password123' }
  end

  describe 'GET /patients/:patient_id/health_metrics' do
    before { sign_in }

    it "returns 200 for the patient's own metrics" do
      get patient_health_metrics_path(patient)
      expect(response).to have_http_status(:ok)
    end

    it 'returns 404 when the patient belongs to another user' do
      other_patient = create(:patient, user: create(:user))
      get patient_health_metrics_path(other_patient)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /health_metrics/:id' do
    before { sign_in }

    it 'returns 200 for an owned metric' do
      get health_metric_path(metric)
      expect(response).to have_http_status(:ok)
    end

    it 'redirects away when the metric belongs to another user' do
      other_metric = create(:health_metric, patient: create(:patient, user: create(:user)))
      get health_metric_path(other_metric)
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET /patients/:patient_id/health_metrics/new' do
    before { sign_in }

    it 'returns 200' do
      get new_patient_health_metric_path(patient)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /patients/:patient_id/health_metrics' do
    before { sign_in }

    context 'with valid params' do
      it 'creates the metric and redirects to show', :aggregate_failures do
        expect do
          post patient_health_metrics_path(patient),
               params: { health_metric: { name: 'Weight', unit: 'kg' } }
        end.to change(HealthMetric, :count).by(1)
        expect(response).to redirect_to(health_metric_path(HealthMetric.last))
      end
    end

    context 'with invalid params' do
      it 'returns 422 and re-renders new' do
        post patient_health_metrics_path(patient),
             params: { health_metric: { name: '', unit: 'kg' } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    it "cannot create a metric for another user's patient" do
      other_patient = create(:patient, user: create(:user))
      post patient_health_metrics_path(other_patient),
           params: { health_metric: { name: 'Weight', unit: 'kg' } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /health_metrics/:id/edit' do
    before { sign_in }

    it 'returns 200 for an owned metric' do
      get edit_health_metric_path(metric)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /health_metrics/:id' do
    before { sign_in }

    context 'with valid params' do
      it 'updates the metric and redirects to show', :aggregate_failures do
        patch health_metric_path(metric), params: { health_metric: { name: 'Updated Name', unit: 'lbs' } }
        expect(response).to redirect_to(health_metric_path(metric))
        expect(metric.reload.name).to eq('Updated Name')
      end
    end

    context 'with invalid params' do
      it 'returns 422 and re-renders edit' do
        patch health_metric_path(metric), params: { health_metric: { name: '', unit: 'kg' } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    it "cannot update another user's metric" do
      other_metric = create(:health_metric, patient: create(:patient, user: create(:user)))
      patch health_metric_path(other_metric), params: { health_metric: { name: 'Hacked', unit: 'kg' } }
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'DELETE /health_metrics/:id' do
    before { sign_in }

    it 'destroys the metric and redirects to index', :aggregate_failures do
      metric_to_delete = create(:health_metric, patient: patient)
      expect do
        delete health_metric_path(metric_to_delete)
      end.to change(HealthMetric, :count).by(-1)
      expect(response).to redirect_to(patient_health_metrics_path(patient))
    end

    it "cannot destroy another user's metric" do
      other_metric = create(:health_metric, patient: create(:patient, user: create(:user)))
      delete health_metric_path(other_metric)
      expect(response).to redirect_to(root_path)
    end
  end
end
