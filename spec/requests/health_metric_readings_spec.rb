require 'rails_helper'

RSpec.describe 'HealthMetricReadings', type: :request do
  let(:user)    { create(:user) }
  let(:patient) { create(:patient, user: user) }
  let(:metric)  { create(:health_metric, patient: patient) }
  let(:reading) { create(:health_metric_reading, health_metric: metric) }

  def sign_in(usr = user)
    post session_path, params: { email_address: usr.email_address, password: 'password123' }
  end

  describe 'GET /health_metrics/:health_metric_id/readings/new' do
    before { sign_in }

    it 'returns 200 for an owned metric' do
      get new_health_metric_reading_path(metric)
      expect(response).to have_http_status(:ok)
    end

    it 'redirects away when the metric belongs to another user' do
      other_metric = create(:health_metric, patient: create(:patient, user: create(:user)))
      get new_health_metric_reading_path(other_metric)
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'POST /health_metrics/:health_metric_id/readings' do
    before { sign_in }

    context 'with valid params' do
      it 'creates the reading and redirects to the metric show page', :aggregate_failures do
        expect do
          post health_metric_readings_path(metric),
               params: { health_metric_reading: { recorded_at: Time.current, value: 72.5 } }
        end.to change(HealthMetricReading, :count).by(1)
        expect(response).to redirect_to(health_metric_path(metric))
      end
    end

    context 'with invalid params' do
      it 'returns 422 and re-renders new' do
        post health_metric_readings_path(metric),
             params: { health_metric_reading: { recorded_at: nil, value: 72.5 } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    it "cannot create a reading for another user's metric" do
      other_metric = create(:health_metric, patient: create(:patient, user: create(:user)))
      post health_metric_readings_path(other_metric),
           params: { health_metric_reading: { recorded_at: Time.current, value: 72.5 } }
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET /readings/:id/edit' do
    before { sign_in }

    it 'returns 200 for an owned reading' do
      get edit_reading_path(reading)
      expect(response).to have_http_status(:ok)
    end

    it 'redirects away when the reading belongs to another user' do
      other_reading = create(:health_metric_reading,
                             health_metric: create(:health_metric,
                                                   patient: create(:patient, user: create(:user))))
      get edit_reading_path(other_reading)
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'PATCH /readings/:id' do
    before { sign_in }

    context 'with valid params' do
      it 'updates the reading and redirects to the metric show page', :aggregate_failures do
        patch reading_path(reading), params: { health_metric_reading: { value: 80.0 } }
        expect(response).to redirect_to(health_metric_path(metric))
        expect(reading.reload.value).to eq(80.0)
      end
    end

    context 'with invalid params' do
      it 'returns 422 and re-renders edit' do
        patch reading_path(reading), params: { health_metric_reading: { value: nil } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    it "cannot update another user's reading" do
      other_reading = create(:health_metric_reading,
                             health_metric: create(:health_metric,
                                                   patient: create(:patient, user: create(:user))))
      patch reading_path(other_reading), params: { health_metric_reading: { value: 99.0 } }
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'DELETE /readings/:id' do
    before { sign_in }

    it 'destroys the reading and redirects to the metric show page', :aggregate_failures do
      reading_to_delete = create(:health_metric_reading, health_metric: metric)
      expect do
        delete reading_path(reading_to_delete)
      end.to change(HealthMetricReading, :count).by(-1)
      expect(response).to redirect_to(health_metric_path(metric))
    end

    it "cannot destroy another user's reading" do
      other_reading = create(:health_metric_reading,
                             health_metric: create(:health_metric,
                                                   patient: create(:patient, user: create(:user))))
      delete reading_path(other_reading)
      expect(response).to redirect_to(root_path)
    end
  end
end
