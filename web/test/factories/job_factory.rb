::FactoryBot.define do
  factory :job do
    user
    status { :initiated }
    kind { :test_log }
    args { Base64.encode64(Marshal.dump(TestArgs.new)) }
  end
end
