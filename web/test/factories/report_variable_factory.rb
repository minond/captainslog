::FactoryBot.define do
  factory :report_variable do
    user
    report
    label { "Testing" }
  end
end
