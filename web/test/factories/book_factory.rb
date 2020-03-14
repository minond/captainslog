::FactoryBot.define do
  factory :book do
    user
    sequence(:name) { |n| "Testing #{n}" }
    sequence(:slug) { |n| "testing-#{n}" }
    grouping { :none }
  end
end
