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

      response(400, 'Invalid params') do
        context 'when given non camelCase params' do
          let(:params) do
            {
              data: {
                attributes: {
                  following_id: user_to_follow.id
                }
              }
            }
          end

          run_test! do
            expect(response_body).to match(
              {
                errors: [
                  {
                    error: 'Params following_id must be in camelCase(followingId)',
                    errorCode: 'GN-1',
                    errorHandling: "Please ensure you've entered the correct parameters"
                  }
                ]
              }
            )
          end
        end

        context 'when followingId is not present' do
          before { params[:data][:attributes][:followingId] = nil }

          run_test! do
            expect(response_body).to match(
              {
                errors: [
                  {
                    error: 'Following ID cannot be null',
                    errorCode: 'GN-1',
                    errorHandling: "Please ensure you've entered the correct parameters"
                  }
                ]
              }
            )
          end
        end

        context 'when user tries to follow themselves' do
          let(:user_to_follow) { user }

          run_test! do
            expect(response_body).to match(
              {
                errors: [
                  {
                    error: 'User cannot follow themselves',
                    errorCode: 'GN-1',
                    errorHandling: "Please ensure you've entered the correct parameters"
                  }
                ]
              }
            )
          end
        end

        context 'when user has already follow the user to be followed' do
          before { user.follow(user_to_follow) }

          run_test! do
            expect(response_body).to match(
              {
                errors: [
                  {
                    error: 'User has been followed before',
                    errorCode: 'GN-1',
                    errorHandling: "Please ensure you've entered the correct parameters"
                  }
                ]
              }
            )
          end
        end
      end
    end
  end
end
