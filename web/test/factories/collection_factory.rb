::FactoryBot.define do
  factory :collection do
    book
    datetime { Time.current }
  end
end
