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

        context 'when user to follow does not exist' do
          before { params[:data][:attributes][:followingId] = 'foo' }

          run_test! do
            expect(response_body).to match(
              {
                errors: [
                  {
                    error: 'User to follow not found',
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

      response(201, 'successfully follow other user') do
        context 'when user and the user to be followed exists' do
          run_test! do
            follows = Follow.last

            expect(response_body).to match(
              {
                data: {
                  id: follows.id.to_s,
                  type: 'follow',
                  attributes: {
                    createdAt: follows.created_at.as_json
                  },
                  relationships: {
                    follower: {
                      data: {
                        id: follows.follower.id.to_s,
                        type: 'user'
                      }
                    },
                    following: {
                      data: {
                        id: follows.following.id.to_s,
                        type: 'user'
                      }
                    }
                  }
                }
              }
            )
          end
        end
      end
    end
  end

  path '/users/{user_id}/followings/{user_to_unfollow_id}' do
    parameter name: 'user_id', in: :path, type: :string, description: 'user_id'
    parameter name: 'user_to_unfollow_id', in: :path, type: :string, description: 'user_to_unfollow_id'

    delete('unfollow another user') do
      tags 'Unfollows'
      consumes 'application/json'

      let(:user) { create(:user).reload }
      let(:user_id) { user.id }
      let(:user_to_unfollow) { create(:user).reload }
      let(:user_to_unfollow_id) { user_to_unfollow.id }

      before { user.follow(user_to_unfollow) }

      response(400, 'Invalid params') do
        context 'when user tries to unfollow themselves' do
          let(:user_to_unfollow_id) { user.id }

          run_test! do
            expect(response_body).to match(
              {
                errors: [
                  {
                    error: 'User cannot unfollow themselves',
                    errorCode: 'GN-1',
                    errorHandling: "Please ensure you've entered the correct parameters"
                  }
                ]
              }
            )
          end
        end

        context "when user hasn't followed the user to unfollow yet" do
          before { user.unfollow(user_to_unfollow) }

          run_test! do
            expect(response_body).to match(
              {
                errors: [
                  {
                    error: "User hasn't been followed before",
                    errorCode: 'GN-1',
                    errorHandling: "Please ensure you've entered the correct parameters"
                  }
                ]
              }
            )
          end
        end
      end

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

        context 'when user to unfollow does not exist' do
          let(:user_to_unfollow_id) { 'foo' }

          run_test! do
            expect(response_body).to match(
              {
                errors: [
                  {
                    error: 'User to unfollow not found',
                    errorCode: 'GN-2',
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
