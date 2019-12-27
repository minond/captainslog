::FactoryBot.define do
  factory :entry do
    book
    collection
    user
    original_text { "Test log entry" }
  end
end
