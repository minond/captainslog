::FactoryBot.define do
  factory :entry do
    book
    collection
    original_text { "Test log entry" }
  end
end
