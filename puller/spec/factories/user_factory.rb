FactoryBot.define do
  factory :user do
    email { Faker::Internet.safe_email }
  end
end
