FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { password }
    role { :guest }

    trait :guest do
      role { :guest }
    end

    trait :host do
      role { :host }
    end

    trait :maintainer do
      role { :maintainer }
    end

    trait :locked do
      failed_attempts { User::MAX_FAILED_ATTEMPTS }
      locked_at { Time.current }
    end
  end
end
