FactoryBot.define do
  factory :sleep_record do
    user { create(:user) }
    sleep_time { 1.hour.ago }
    wake_time { Time.now }
    duration { wake_time - sleep_time }
  end
end
