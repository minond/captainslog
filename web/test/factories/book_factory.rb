::FactoryBot.define do
  factory :book do
    user
    name { "Testing" }
    slug { "testing" }
    grouping { :none }
  end
end
