class HealthMetric < ApplicationRecord
  belongs_to :patient
  has_many :readings, class_name: 'HealthMetricReading', dependent: :destroy

  validates :name, :unit, presence: true
  validates :name, uniqueness: { scope: :patient_id, case_sensitive: false }
end
