::FactoryBot.define do
  factory :report_output do
    user
    report
    label { "Testing" }
    kind { :table }
  end
end
