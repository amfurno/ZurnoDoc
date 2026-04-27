FactoryBot.define do
  factory :session do
    association :user
    user_agent { "TestBrowser" }
    ip_address { "127.0.0.1" }
    expires_at { Time.current + Session::SESSION_LENGTH }
    absolute_expires_at { Time.current + Session::ABSOLUTE_TTL }

    trait :expired do
      expires_at { 1.minute.ago }
      absolute_expires_at { Time.current + Session::ABSOLUTE_TTL }
    end

    trait :absolute_expired do
      expires_at { 1.minute.ago }
      absolute_expires_at { 1.minute.ago }
    end
  end
end
