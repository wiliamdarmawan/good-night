require 'swagger_helper'

RSpec.describe 'follows', type: :request do
  path '/users/{user_id}/followings' do
    parameter name: 'user_id', in: :path, type: :string, description: 'user_id'

    post('follow another user') do
      tags 'Follows'
      consumes 'application/json'

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :object,
            properties: {
              attributes: {
                type: :object,
                properties: {
                  followingId: { type: :string }
                },
                required: %w[followingId]
              }
            },
            required: %w[attributes]
          }
        },
        required: %w[data]
      }

      let(:user) { create(:user) }
      let(:user_to_follow) { create(:user) }
      let(:user_id) { user.id }
      let(:params) do
        {
          data: {
            attributes: {
              followingId: user_to_follow.id
            }
          }
        }
      end
    end
  end
end
