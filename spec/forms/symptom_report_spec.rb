require 'rails_helper'

RSpec.describe SymptomReport do
  subject(:report) { described_class.new(patient: patient, date: date) }

  let(:patient) { create(:patient, user: create(:user)) }
  let(:date) { Date.current }

  describe 'validations' do
    it 'is invalid without a patient' do
      report.patient = nil
      expect(report).not_to be_valid
    end

    it 'is invalid without a date' do
      report.date = nil
      expect(report).not_to be_valid
    end

    it 'sets date to nil when it cannot be parsed' do
      report.date = 'not-a-date'
      expect(report.date).to be_nil
    end

    it 'is invalid when the date cannot be parsed' do
      report.date = 'not-a-date'
      expect(report).not_to be_valid
    end
  end

  describe '#save' do
    it 'creates entries for checked existing symptoms' do
      symptom = create(:symptom, patient: patient, name: 'Headache')
      report.symptom_ids = [symptom.id]

      expect { report.save }.to change(SymptomEntry, :count).by(1)
    end

    it 'creates the entry on the checked symptom' do
      symptom = create(:symptom, patient: patient, name: 'Headache')
      report.symptom_ids = [symptom.id]

      report.save
      expect(symptom.entries.find_by(date: date)).to be_present
    end

    it 'creates new symptoms from newline-delimited text and reuses them case-insensitively' do
      create(:symptom, patient: patient, name: 'Nausea')
      report.new_symptoms_text = "nausea\nFatigue\n\n  Fatigue  \n"

      expect { report.save }.to change(Symptom, :count).by(1).and change(SymptomEntry, :count).by(2)
    end

    it 'reuses the existing symptom case-insensitively instead of duplicating it' do
      existing = create(:symptom, patient: patient, name: 'Nausea')
      report.new_symptoms_text = "nausea\nFatigue"

      report.save
      expect(existing.entries.reload.find_by(date: date)).to be_present
    end

    it 'deduplicates repeated new symptom names within the same submission' do
      report.new_symptoms_text = "Fatigue\n  Fatigue  "

      report.save
      expect(patient.symptoms.where(name: 'Fatigue').count).to eq(1)
    end

    it 'does not duplicate an entry that already exists for the date' do
      symptom = create(:symptom, patient: patient, name: 'Headache')
      create(:symptom_entry, symptom: symptom, date: date)
      report.symptom_ids = [symptom.id]

      expect { report.save }.not_to change(SymptomEntry, :count)
    end

    it 'returns false and does not persist anything when invalid' do
      report.date = nil
      expect(report.save).to be false
    end

    it 'ignores symptom ids belonging to another patient' do
      other_symptom = create(:symptom, patient: create(:patient, user: create(:user)))
      report.symptom_ids = [other_symptom.id]

      expect { report.save }.not_to change(SymptomEntry, :count)
    end
  end
end
