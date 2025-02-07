# frozen_string_literal: true

class Constants
  ERROR_MAPPINGS = {
    InvalidParamsError => {
      message: 'Invalid Parameter Error',
      code: 'GN-1',
      handling: "Please ensure you've entered the correct parameters",
      status: :bad_request
    },
    RecordNotFoundError => {
      message: 'Record Not Found',
      code: 'GN-2',
      handling: "Please ensure you've entered the correct parameters",
      status: :not_found
    }
  }.freeze
end
