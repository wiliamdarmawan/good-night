# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Paginable
  rescue_from StandardError, with: :handle_error

  protected

  def check_camel_case(attributes)
    attributes.each do |key, _|
      if key.to_s != key.to_s.camelize(:lower)
        raise InvalidParamsError,
              "Params #{key} must be in camelCase(#{key.to_s.camelize(:lower)})"
      end
    end
  end

  def parsed_params
    params.to_unsafe_h.deep_transform_keys!(&:underscore).with_indifferent_access
  end

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
