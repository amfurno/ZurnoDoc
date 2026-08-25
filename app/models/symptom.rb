class Symptom < ApplicationRecord
  belongs_to :patient
  has_many :entries, class_name: 'SymptomEntry', dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :patient_id, case_sensitive: false }
end
