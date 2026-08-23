require 'rails_helper'

RSpec.describe SymptomEntry, type: :model do
  subject(:entry) { build(:symptom_entry, symptom: symptom) }

  let(:patient) { create(:patient, user: create(:user)) }
  let(:symptom) { create(:symptom, patient: patient) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(entry).to be_valid
    end

    it 'is invalid without a date' do
      entry.date = nil
      expect(entry).not_to be_valid
    end

    it 'is invalid without a symptom' do
      entry.symptom = nil
      expect(entry).not_to be_valid
    end

    describe 'date uniqueness per symptom' do
      before { create(:symptom_entry, symptom: symptom, date: Date.current) }

      it 'is invalid when an entry already exists for the same symptom and date' do
        entry.date = Date.current
        expect(entry).not_to be_valid
      end

      it 'is valid for a different date' do
        entry.date = Date.current - 1.day
        expect(entry).to be_valid
      end

      it 'is valid for the same date on a different symptom' do
        other_symptom = create(:symptom, patient: patient)
        entry.symptom = other_symptom
        entry.date = Date.current
        expect(entry).to be_valid
      end
    end
  end

  describe 'associations' do
    it 'belongs to a symptom' do
      expect(described_class.reflect_on_association(:symptom).macro).to eq(:belongs_to)
    end
  end
end
