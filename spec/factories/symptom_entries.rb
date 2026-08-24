FactoryBot.define do
  factory :symptom_entry do
    symptom
    date { Date.current }
  end
end
