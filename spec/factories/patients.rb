FactoryBot.define do
  factory :patient do
    association :user
    sequence(:name) { |n| "Patient #{n}" }
  end
end
