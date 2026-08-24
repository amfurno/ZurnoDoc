require 'rails_helper'

RSpec.describe HealthMetricReading, type: :model do
  subject(:reading) { build(:health_metric_reading, health_metric: metric) }

  let(:patient) { create(:patient, user: create(:user)) }
  let(:metric)  { create(:health_metric, patient: patient) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(reading).to be_valid
    end

    it 'is invalid without a recorded_at' do
      reading.recorded_at = nil
      expect(reading).not_to be_valid
    end

    it 'is invalid without a value' do
      reading.value = nil
      expect(reading).not_to be_valid
    end

    it 'is invalid without a health_metric' do
      reading.health_metric = nil
      expect(reading).not_to be_valid
    end

    it 'is invalid with a non-numeric value' do
      reading.value = 'abc'
      expect(reading).not_to be_valid
    end

    it 'is valid with a positive value' do
      reading.value = 120.5
      expect(reading).to be_valid
    end

    it 'is valid with a negative value' do
      reading.value = -3.2
      expect(reading).to be_valid
    end

    it 'is valid with zero' do
      reading.value = 0
      expect(reading).to be_valid
    end

    it 'allows multiple readings on the same day for the same metric' do
      create(:health_metric_reading, health_metric: metric, recorded_at: Time.current)
      reading.recorded_at = Time.current
      expect(reading).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a health_metric' do
      expect(described_class.reflect_on_association(:health_metric).macro).to eq(:belongs_to)
    end
  end
end
