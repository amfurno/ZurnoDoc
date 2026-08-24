FactoryBot.define do
  factory :symptom do
    patient
    sequence(:name) { |n| "Symptom #{n}" }
  end
end
