::FactoryBot.define do
  factory :extractor do
    book
    user
    label { "testing" }
    match { "/*/" }
    data_type { :string }
  end
end
