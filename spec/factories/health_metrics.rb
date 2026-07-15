FactoryBot.define do
  factory :health_metric do
    patient
    sequence(:name) { |n| "Metric #{n}" }
    unit { "kg" }
  end
end
