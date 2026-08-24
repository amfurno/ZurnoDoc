class SymptomEntry < ApplicationRecord
  belongs_to :symptom

  validates :date, presence: true
  validates :date, uniqueness: { scope: :symptom_id }
end
