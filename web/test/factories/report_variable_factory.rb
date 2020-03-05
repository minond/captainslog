::FactoryBot.define do
  factory :report_variable do
    report
    label { "Testing" }
    query { "select 1" }
    default_value { "1" }
  end
end
