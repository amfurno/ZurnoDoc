class Medication < ApplicationRecord
  belongs_to :patient
  belongs_to :doctor, optional: true

  validates :name, presence: true
end
