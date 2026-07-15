require "rails_helper"

RSpec.describe HealthMetric, type: :model do
  subject(:health_metric) { build(:health_metric, patient: patient) }

  let(:patient) { create(:patient, user: create(:user)) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(health_metric).to be_valid
    end

    it "is invalid without a name" do
      health_metric.name = nil
      expect(health_metric).not_to be_valid
    end

    it "is invalid without a unit" do
      health_metric.unit = nil
      expect(health_metric).not_to be_valid
    end

    it "is invalid without a patient" do
      health_metric.patient = nil
      expect(health_metric).not_to be_valid
    end

    describe "name uniqueness per patient" do
      before { create(:health_metric, patient: patient, name: "Weight") }

      it "is invalid when the same name already exists for the patient" do
        health_metric.name = "Weight"
        expect(health_metric).not_to be_valid
      end

      it "is invalid when the same name exists with different case" do
        health_metric.name = "weight"
        expect(health_metric).not_to be_valid
      end

      it "is valid when the same name exists for a different patient" do
        other_patient = create(:patient, user: create(:user))
        health_metric.patient = other_patient
        health_metric.name = "Weight"
        expect(health_metric).to be_valid
      end
    end
  end

  describe "associations" do
    it "belongs to a patient" do
      expect(described_class.reflect_on_association(:patient).macro).to eq(:belongs_to)
    end

    it "has many readings dependent destroy" do
      reflection = described_class.reflect_on_association(:readings)
      expect(reflection.macro).to eq(:has_many)
      expect(reflection.options[:dependent]).to eq(:destroy)
    end

    it "destroys associated readings when destroyed" do
      metric = create(:health_metric, patient: patient)
      create(:health_metric_reading, health_metric: metric)
      expect { metric.destroy }.to change(HealthMetricReading, :count).by(-1)
    end
  end
end
