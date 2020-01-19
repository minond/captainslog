::FactoryBot.define do
  factory :shorthand do
    book
    priority { 0 }
    expansion { "ok" }
    match { "ok" }
    text { "ok" }
  end
end
