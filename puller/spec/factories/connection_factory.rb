FactoryBot.define do
  factory :connection do
    user

    source { :fitbit }
  end
end
