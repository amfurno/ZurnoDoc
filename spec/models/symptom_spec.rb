require 'rails_helper'

RSpec.describe Symptom, type: :model do
  subject(:symptom) { build(:symptom, patient: patient) }

  let(:patient) { create(:patient, user: create(:user)) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(symptom).to be_valid
    end

    it 'is invalid without a name' do
      symptom.name = nil
      expect(symptom).not_to be_valid
    end

    it 'is invalid without a patient' do
      symptom.patient = nil
      expect(symptom).not_to be_valid
    end

    describe 'name uniqueness per patient' do
      before { create(:symptom, patient: patient, name: 'Headache') }

      it 'is invalid when the same name already exists for the patient' do
        symptom.name = 'Headache'
        expect(symptom).not_to be_valid
      end

      it 'is invalid when the same name exists with different case' do
        symptom.name = 'headache'
        expect(symptom).not_to be_valid
      end

      it 'is valid when the same name exists for a different patient' do
        other_patient = create(:patient, user: create(:user))
        symptom.patient = other_patient
        symptom.name = 'Headache'
        expect(symptom).to be_valid
      end
    end
  end

  describe 'associations' do
    it 'belongs to a patient' do
      expect(described_class.reflect_on_association(:patient).macro).to eq(:belongs_to)
    end

    it 'has many entries' do
      reflection = described_class.reflect_on_association(:entries)
      expect(reflection.macro).to eq(:has_many)
    end

    it 'destroys entries dependently' do
      reflection = described_class.reflect_on_association(:entries)
      expect(reflection.options[:dependent]).to eq(:destroy)
    end

    it 'destroys associated entries when destroyed' do
      symptom.save!
      create(:symptom_entry, symptom: symptom)
      expect { symptom.destroy }.to change(SymptomEntry, :count).by(-1)
    end
  end
end
