describe CalculateSleepRecordService do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:sleep_clock_in) { create(:clock_in, user: user, clock_in_type: :sleep, created_at: 8.hours.ago) }
  let(:wake_clock_in) { create(:clock_in, user: user, clock_in_type: :wake, created_at: Time.now) }
  
  describe '#call' do
    context 'when wake_clock_in is not a ClockIn object' do
      it 'raises an InvalidParamsError' do
        expect do
          described_class.call(wake_clock_in: nil, sleep_clock_in: sleep_clock_in)
        end.to raise_error(InvalidParamsError, "Not a Clock In object")
      end
    end

    context 'when sleep_clock_in is not a ClockIn object' do
      it 'raises an InvalidParamsError' do
        expect do
          described_class.call(wake_clock_in: wake_clock_in, sleep_clock_in: nil)
        end.to raise_error(InvalidParamsError, "Not a Clock In object")
      end
    end

    context 'when wake and sleep clock ins belong to different users' do
      let(:other_user_sleep_clock_in) { create(:clock_in, user: other_user, clock_in_type: :sleep, created_at: 8.hours.ago) }
      
      it 'raises an InvalidParamsError' do
        expect do
          described_class.call(wake_clock_in: wake_clock_in, sleep_clock_in: other_user_sleep_clock_in)
        end.to raise_error(InvalidParamsError, "Can't calculate sleep record of different users")
      end
    end

    context 'when wake clock-in is of incorrect type' do
      let(:invalid_wake_clock_in) { create(:clock_in, user: user, clock_in_type: :sleep, created_at: 8.hours.ago) }
      
      it 'raises an InvalidParamsError' do
        expect do
          described_class.call(wake_clock_in: invalid_wake_clock_in, sleep_clock_in: sleep_clock_in)
        end.to raise_error(InvalidParamsError, "Wrong type of clock in")
      end
    end

    context 'when sleep clock-in is of incorrect type' do
      let(:invalid_sleep_clock_in) { create(:clock_in, user: user, clock_in_type: :wake, created_at: 8.hours.ago) }
      
      it 'raises an InvalidParamsError' do
        expect do
          described_class.call(wake_clock_in: wake_clock_in, sleep_clock_in: invalid_sleep_clock_in)
        end.to raise_error(InvalidParamsError, "Wrong type of clock in")
      end
    end

    context 'when wake time is earlier than sleep time' do
      let(:invalid_wake_clock_in) { create(:clock_in, user: user, clock_in_type: :wake, created_at: 10.hours.ago) }
      
      it 'raises an InvalidParamsError' do
        expect do
          described_class.call(wake_clock_in: invalid_wake_clock_in, sleep_clock_in: sleep_clock_in)
        end.to raise_error(InvalidParamsError, "Wake time cannot be earlier than sleep time")
      end
    end

    context 'when valid wake and sleep clock-ins are provided' do
      it 'creates a sleep record successfully' do
        expect do
          described_class.call(wake_clock_in: wake_clock_in, sleep_clock_in: sleep_clock_in)
        end.to change(SleepRecord, :count).by(1)

        sleep_record = SleepRecord.last
        expect(sleep_record.user).to eq(user)
        expect(sleep_record.wake_time).to eq(wake_clock_in.created_at)
        expect(sleep_record.sleep_time).to eq(sleep_clock_in.created_at)
        expect(sleep_record.duration).to eq(wake_clock_in.created_at - sleep_clock_in.created_at)
      end
    end
  end
end
