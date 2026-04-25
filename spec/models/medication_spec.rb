require 'rails_helper'

RSpec.describe Medication, type: :model do
  subject(:medication) { build(:medication, patient: patient) }

  let(:user) { create(:user) }
  let(:patient) { create(:patient, user: user) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(medication).to be_valid
    end

    it 'is invalid without a name' do
      medication.name = nil
      expect(medication).not_to be_valid
    end

    it 'is invalid without a patient' do
      medication.patient = nil
      expect(medication).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a patient' do
      expect(Medication.reflect_on_association(:patient).macro).to eq(:belongs_to)
    end

    it 'belongs to an optional doctor' do
      expect(Medication.reflect_on_association(:doctor).macro).to eq(:belongs_to)
      expect(Medication.reflect_on_association(:doctor).options[:optional]).to be(true)
    end
  end

  describe '.active scope' do
    it 'returns only medications without a date_stopped' do
      active = create(:medication, :active, patient: patient)
      _past  = create(:medication, :past, patient: patient)
      expect(Medication.active).to include(active)
    end

    it 'excludes medications with a date_stopped' do
      past = create(:medication, :past, patient: patient)
      expect(Medication.active).not_to include(past)
    end
  end

  describe '.past scope' do
    it 'returns only medications with a date_stopped' do
      past    = create(:medication, :past, patient: patient)
      _active = create(:medication, :active, patient: patient)
      expect(Medication.past).to include(past)
    end

    it 'excludes medications without a date_stopped' do
      active = create(:medication, :active, patient: patient)
      expect(Medication.past).not_to include(active)
    end
  end

  describe '.sorted' do
    let!(:med_a) { create(:medication, patient: patient, name: 'Aspirin', dosage: '100mg', date_started: '2026-01-01') }
    let!(:med_b) { create(:medication, patient: patient, name: 'Zyrtec',  dosage: '10mg',  date_started: '2026-03-01') }

    it 'sorts by name ascending by default' do
      expect(Medication.sorted(nil, nil).to_a).to eq([ med_a, med_b ])
    end

    it 'sorts by name ascending' do
      expect(Medication.sorted('name', 'asc').to_a).to eq([ med_a, med_b ])
    end

    it 'sorts by name descending' do
      expect(Medication.sorted('name', 'desc').to_a).to eq([ med_b, med_a ])
    end

    it 'sorts by dosage ascending' do
      expect(Medication.sorted('dosage', 'asc').to_a).to eq([ med_a, med_b ])
    end

    it 'sorts by date_started ascending' do
      expect(Medication.sorted('date_started', 'asc').to_a).to eq([ med_a, med_b ])
    end

    it 'sorts by date_started descending' do
      expect(Medication.sorted('date_started', 'desc').to_a).to eq([ med_b, med_a ])
    end

    it 'falls back to name when given an invalid column' do
      expect(Medication.sorted('injected_column; DROP TABLE medications;--', 'asc').to_a).to eq([ med_a, med_b ])
    end

    it 'falls back to asc when given an invalid direction' do
      expect(Medication.sorted('name', 'sideways').to_a).to eq([ med_a, med_b ])
    end

    context 'when sorting by doctor_name' do
      let(:doctor_a) { create(:doctor, patient: patient, name: 'Dr. Adams') }
      let(:doctor_z) { create(:doctor, patient: patient, name: 'Dr. Zane') }
      let!(:med_with_doctor_z) { create(:medication, patient: patient, name: 'Aspirin', doctor: doctor_z) }
      let!(:med_with_doctor_a) { create(:medication, patient: patient, name: 'Zyrtec',  doctor: doctor_a) }
      let!(:med_no_doctor)     { create(:medication, patient: patient, name: 'Metformin') }

      it 'sorts by doctor name ascending with nulls last' do
        result = Medication.sorted('doctor_name', 'asc').to_a
        expect(result.index(med_with_doctor_a)).to be < result.index(med_with_doctor_z)
        expect(result.last).to eq(med_no_doctor)
      end

      it 'sorts by doctor name descending with nulls last' do
        result = Medication.sorted('doctor_name', 'desc').to_a
        expect(result.index(med_with_doctor_z)).to be < result.index(med_with_doctor_a)
        expect(result.last).to eq(med_no_doctor)
      end
    end
  end
end
