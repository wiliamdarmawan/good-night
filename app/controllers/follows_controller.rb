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
end
