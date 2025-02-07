class SleepRecordSerializer < BaseSerializer
  set_id :id
  set_type :sleep_record

  attribute :wake_time
  attribute :sleep_time
  attribute :duration do |object|
    TimeDifference.between(object.wake_time, object.sleep_time).humanize
  end
  belongs_to :user
end
