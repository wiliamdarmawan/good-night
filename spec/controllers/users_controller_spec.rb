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

      response(404, 'Record not found') do
        context 'when user does not exist' do
          let(:user_id) { 'foo' }

          run_test! do
            expect(response_body).to match(
              {
                errors: [
                  {
                    error: 'User not found',
                    errorCode: 'GN-2',
                    errorHandling: "Please ensure you've entered the correct parameters"
                  }
                ]
              }
            )
          end
        end
      end

      response(500, 'Internal Server Error') do
        context 'when something unexpected happened' do
          before { allow(GetUserService).to receive(:call).and_raise(StandardError) }

          run_test! do
            expect(response_body).to match(
              {
                errors: [
                  {
                    error: 'An unexpected error occurred',
                    errorCode: 'GN-999',
                    errorHandling: "Please contact support"
                  }
                ]
              }
            )
          end
        end
      end

      response(200, 'get user followings feed') do
        let(:followed_user) { create(:user) }

        before { user.follow(followed_user) }

        context "when user is not following anyone" do
          before { user.unfollow(followed_user) }

          run_test! do
            expect(response_body).to match(
              {
                data: [],
                meta: {
                  total: 0,
                  pages: 1
                },
                links: {
                  self: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[size\]=10\z}
                }
              }
            )
          end
        end
      end
    end
  end
end
