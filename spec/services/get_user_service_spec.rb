describe GetUserService do
  let(:user) { create(:user) }
  let(:user_id) { user.id }

  describe "#call" do
  context 'when user is not found' do
    let(:user_id) { 'foo' }

    context 'with default error message' do
      it 'raises error with default error message' do
        expect { described_class.call(user_id) }.to raise_error(RecordNotFoundError, 'User not found')
      end
    end

    context 'with custom error message' do
      let(:error_message) { 'User not found for some reason' }

      it 'raises error with custom error message' do
        expect { described_class.call(user_id, error_message: error_message) }.to raise_error(RecordNotFoundError, error_message)
      end
    end
  end

  context 'when user is found' do
    it 'returns user information' do
      fetched_user = described_class.call(user_id)
      expect(fetched_user).to eq(user)
    end
  end
  end
end