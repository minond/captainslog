::FactoryBot.define do
  factory :extractor do
    book
    label { "testing" }
    match { "/*/" }
    type { 0 }
  end
end
