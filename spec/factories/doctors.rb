FactoryBot.define do
  factory :doctor do
    patient
    sequence(:name) { |n| "Dr. Doctor #{n}" }
    practice { 'General Practice' }
    speciality { 'General Medicine' }
  end
end
