::FactoryBot.define do
  factory :connection do
    user
    book
    data_source { :fitbit }
  end
end
