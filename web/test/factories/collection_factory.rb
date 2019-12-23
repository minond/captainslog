::FactoryBot.define do
  factory :collection do
    book
    datetime { Date.current }

    trait :past do
      datetime { Date.yesterday }
    end

    trait :future do
      datetime { Date.tomorrow }
    end
  end
end
