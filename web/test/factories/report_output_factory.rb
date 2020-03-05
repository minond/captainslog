::FactoryBot.define do
  factory :report_output do
    report
    label { "Testing" }
    kind { :table }
    width { "100%" }
    height { "100px" }
    query { "select 1" }
  end
end
