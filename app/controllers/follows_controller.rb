class FollowsController < ApplicationController
  def create
    check_camel_case(params[:data][:attributes])

    user_id = parsed_params[:user_id]
    user = GetUserService.call(user_id)
    following_id = parsed_params.dig(:data, :attributes, :following_id)

    raise InvalidParamsError, 'Following ID cannot be null' unless following_id.present?
    raise InvalidParamsError, 'User cannot follow themselves' if user_id.to_s == following_id.to_s

    user_to_follow = GetUserService.call(following_id, error_message: 'User to follow not found')
    raise InvalidParamsError, 'User has been followed before' if user.following?(user_to_follow)

    following = user.follow(user_to_follow)

    render json: FollowSerializer.new(following).serializable_hash.to_json, status: :created
  end

  def destroy
    user_id = parsed_params[:user_id]
    user = GetUserService.call(user_id)
    user_to_unfollow_id = parsed_params[:id]

    raise InvalidParamsError, 'User cannot unfollow themselves' if user_id.to_s == user_to_unfollow_id.to_s

    user_to_unfollow = GetUserService.call(user_to_unfollow_id, error_message: 'User to unfollow not found')
    raise InvalidParamsError, "User hasn't been followed before" unless user.following?(user_to_unfollow)

    user.unfollow(user_to_unfollow)

    render json: {}, status: :no_content
  end
end
