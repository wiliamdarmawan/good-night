module Helpers
  module ResponseHelpers
    def reload_response_body
      @response_body = nil
    end

    def response_body
      @response_body ||= begin
        JSON.parse(response.body, symbolize_names: true)
      rescue StandardError
        {}
      end
    end
  end
end
