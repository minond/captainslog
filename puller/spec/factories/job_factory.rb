FactoryBot.define do
  factory :job do
    user
    connection

    kind { :test }

    trait :running do
      status { :running }
    end

    trait :done do
      status { :done }
    end

    trait :errored do
      status { :errored }
    end
  end
end
