FactoryBot.define do
  factory :medication do
    association :patient
    sequence(:name) { |n| "Medication #{n}" }
    drug_class { "Analgesic" }
    dosage { "10mg" }
    date_started { "2026-01-01" }
    notes { "Take with food" }
    side_effects { "Nausea" }

    trait :active do
      date_stopped { nil }
    end

    trait :past do
      date_stopped { "2026-02-01" }
    end
  end
end
