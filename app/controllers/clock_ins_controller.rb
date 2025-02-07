class ClockInsController < ApplicationController
  def index
    user_id = parsed_params[:user_id]
    user = GetUserService.call(user_id)

    page = parsed_params[:page] || {}
    pagination_params = {
      number: page[:number] || 1,
      size: page[:size] || 10
    }

    clock_ins = user.clock_ins.order(created_at: :desc)

    render_paginated(clock_ins, pagination_params, serializer: ClockInSerializer)
  end

  def sleep
    user_id = parsed_params[:user_id]
    user = GetUserService.call(user_id)

    raise InvalidParamsError, 'User is sleeping' if user.clock_ins&.last&.sleep?

    clock_in = user.sleep!

    render json: ClockInSerializer.new(clock_in, { params: { show_relationships: true } }).serializable_hash.to_json, status: :created
  end
end
