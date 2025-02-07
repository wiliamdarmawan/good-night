FactoryBot.define do
  factory :clock_in do
    user { create(:user) }
    clock_in_type { :wake }
  end
end
