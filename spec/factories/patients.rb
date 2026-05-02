FactoryBot.define do
  factory :patient do
    user
    sequence(:name) { |n| "Patient #{n}" }
  end
end
