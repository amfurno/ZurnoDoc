class HealthMetricReading < ApplicationRecord
  belongs_to :health_metric

  validates :recorded_at, :value, presence: true
  validates :value, numericality: true
end
