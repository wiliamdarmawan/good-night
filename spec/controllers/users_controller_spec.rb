require 'swagger_helper'

RSpec.describe 'users', type: :request do
  let(:user) { create(:user) }
  let(:user_id) { user.id }

  path '/users/{user_id}' do
    parameter name: 'user_id', in: :path, type: :string, description: 'user_id'

    get('user followings feed') do
      tags 'User Followings Feed'
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
