class UsersController < ApplicationController
  def show
    user_id = parsed_params[:id]
    user = GetUserService.call(user_id)

    page = parsed_params[:page] || {}
    pagination_params = {
      number: page[:number] || 1,
      size: page[:size] || 10
    }

    sleep_records = user.followings_sleep_records
                    .where("sleep_records.created_at >= ?", 1.week.ago)
                    .order("sleep_records.created_at DESC, sleep_records.duration DESC")

    render_paginated(sleep_records, pagination_params, serializer: SleepRecordSerializer)
  end
end
