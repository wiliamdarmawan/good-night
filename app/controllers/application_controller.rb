# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Paginable
  rescue_from StandardError, with: :handle_error

  private

  def handle_error(error)
    error_details = Constants::ERROR_MAPPINGS[error.class] || {
      message: 'An unexpected error occurred',
      code: 'GN-999',
      handling: 'Please contact support',
      status: :internal_server_error
    }
    error_message = error.message == error.class.to_s ? error_details[:message] : error.message

    render json: {
      errors: [
        {
          error: error_message,
          errorCode: error_details[:code],
          errorHandling: error_details[:handling]
        }
      ]
    }, status: error_details[:status]
  end
end
