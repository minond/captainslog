::FactoryBot.define do
  factory :extractor do
    book
    user
    label { "testing" }
    match { "/*/" }
    type { 0 }
  end
end
