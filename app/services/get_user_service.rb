class GetUserService
  include ServiceObject

  def initialize(user_id, error_message: 'User not found')
    @user_id = user_id
    @error_message = error_message
  end

  def call
    user = User.find_by(id: @user_id)
    raise RecordNotFoundError, @error_message unless user.present?

    user
  end
end
