require 'swagger_helper'

RSpec.describe 'clock-ins', type: :request do
  let(:user) { create(:user) }
  let(:user_id) { user.id }

  path '/users/{user_id}/clock-ins' do
    parameter name: 'user_id', in: :path, type: :string, description: 'user_id'

    get('user clock in logs') do
      tags 'Clock Ins'
      consumes 'application/json'

      parameter name: :pagination_params, in: :query, schema: {
        type: :object,
        properties: {
          page: {
            type: :object,
            properties: {
              number: { type: :string },
              size: { type: :string }
            }
          }
        }
      }

      let(:pagination_params) { {} }
    end
  end
end
