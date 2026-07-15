FactoryBot.define do
  factory :health_metric_reading do
    health_metric
    recorded_at { Time.current }
    value { 70.5 }
  end
end
