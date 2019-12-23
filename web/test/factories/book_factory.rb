::FactoryBot.define do
  factory :book do
    user
    name { "Testing" }
    grouping { :none }
  end
end
