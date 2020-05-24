FactoryBot.define do
  factory :connection do
    user

    service { :fitbit }
  end
end
