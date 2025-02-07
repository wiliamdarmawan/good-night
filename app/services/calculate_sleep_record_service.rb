class CalculateSleepRecordService
  include ServiceObject

  def initialize(wake_clock_in:, sleep_clock_in:)
    @wake_clock_in = wake_clock_in
    @sleep_clock_in = sleep_clock_in
  end

  def call
    raise InvalidParamsError, "Not a Clock In object" unless @wake_clock_in.is_a?(ClockIn) && @sleep_clock_in.is_a?(ClockIn)
    raise InvalidParamsError, "Can't calculate sleep record of different users" if @wake_clock_in.user != @sleep_clock_in.user
    raise InvalidParamsError, "Wrong type of clock in" unless @wake_clock_in.wake? && @sleep_clock_in.sleep?

    wake_time = @wake_clock_in.created_at
    sleep_time = @sleep_clock_in.created_at

    raise InvalidParamsError, "Wake time cannot be earlier than sleep time" unless wake_time > sleep_time
    duration = wake_time - sleep_time
    SleepRecord.create!(user: @wake_clock_in.user, wake_time: @wake_clock_in.created_at, sleep_time: @sleep_clock_in.created_at, duration: duration)
  end
end
