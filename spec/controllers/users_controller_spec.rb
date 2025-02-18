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

        context "when user's followings does not have any sleep record" do
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

        context "when user's followings has sleep records & no pagination params given" do
          before { (1..15).map { |i| create(:sleep_record, user: followed_user, sleep_time: i.minutes.ago, wake_time: Time.now) } }

          run_test! do
            expect(response_body[:data].count).to eq(10)
            expect(response_body[:data].first[:attributes][:duration].to_i).to be > response_body[:data].second[:attributes][:duration].to_i
            expect(response_body[:data]).to all(include(:id, :type, :attributes, :relationships))
            expect(response_body[:meta]).to match(
              {
                total: 15,
                pages: 2
              }
            )
            expect(response_body[:links]).to match(
              {
                self: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[size\]=10\z},
                next: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[number\]=2&page\[size\]=10\z},
                last: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[number\]=2&page\[size\]=10\z}
              }
            )
          end
        end

        context "when users's followings has sleep records & pagination params number given" do
          before { (1..25).map { |i| create(:sleep_record, user: followed_user, sleep_time: i.minutes.ago, wake_time: Time.now) } }

          let(:pagination_params) do
            {
              page: {
                number: 2
              }
            }
          end

          run_test! do
            expect(response_body[:data].count).to eq(10)
            expect(response_body[:data].first[:attributes][:duration].to_i).to be > response_body[:data].second[:attributes][:duration].to_i
            expect(response_body[:data]).to all(include(:id, :type, :attributes, :relationships))
            expect(response_body[:meta]).to match(
              {
                total: 25,
                pages: 3
              }
            )
            expect(response_body[:links]).to match(
              {
                first: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[size\]=10\z},
                prev: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[size\]=10\z},
                self: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[number\]=2&page\[size\]=10\z},
                next: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[number\]=3&page\[size\]=10\z},
                last: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[number\]=3&page\[size\]=10\z}
              }
            )
          end
        end

        context "when users's followings has sleep records & pagination params size given" do
          before { (1..25).map { |i| create(:sleep_record, user: followed_user, sleep_time: i.minutes.ago, wake_time: Time.now) } }

          let(:pagination_params) do
            {
              page: {
                size: 30,
              }
            }
          end

          run_test! do
            expect(response_body[:data].count).to eq(25)
            expect(response_body[:data].first[:attributes][:duration].to_i).to be > response_body[:data].second[:attributes][:duration].to_i
            expect(response_body[:data]).to all(include(:id, :type, :attributes, :relationships))
            expect(response_body[:meta]).to match(
              {
                total: 25,
                pages: 1
              }
            )
            expect(response_body[:links]).to match(
              {
                self: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[size\]=30\z},
              }
            )
          end
        end

        context "when users's followings has sleep records & pagination params number & size given" do
          before { (1..25).map { |i| create(:sleep_record, user: followed_user, sleep_time: i.minutes.ago, wake_time: Time.now) } }

          let(:pagination_params) do
            {
              page: {
                number: 2,
                size: 5,
              }
            }
          end

          run_test! do
            expect(response_body[:data].count).to eq(5)
            expect(response_body[:data].first[:attributes][:duration].to_i).to be > response_body[:data].second[:attributes][:duration].to_i
            expect(response_body[:data]).to all(include(:id, :type, :attributes, :relationships))
            expect(response_body[:meta]).to match(
              {
                total: 25,
                pages: 5
              }
            )
            expect(response_body[:links]).to match(
              {
                first: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[size\]=5\z},
                prev: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[size\]=5\z},
                self: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[number\]=2&page\[size\]=5\z},
                next: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[number\]=3&page\[size\]=5\z},
                last: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[number\]=5&page\[size\]=5\z}
              }
            )
          end
        end

        context 'when there is only one sleep record from followed users' do
          let!(:sleep_record) { create(:sleep_record, user: followed_user, sleep_time: 10.minutes.ago, wake_time: Time.now) }

          run_test! do
            expect(response_body).to match({
              data: [
                {
                  id: sleep_record.id.to_s,
                  type: 'sleepRecord',
                  attributes: {
                    wakeTime: sleep_record.wake_time.as_json,
                    sleepTime: sleep_record.sleep_time.as_json,
                    duration: TimeDifference.between(sleep_record.wake_time, sleep_record.sleep_time).humanize,
                  },
                  relationships: {
                    user: {
                      data: {
                        id: followed_user.id.to_s,
                        type: 'user',
                      },
                    },
                  },
                }
              ],
              meta: {
                total: 1,
                pages: 1,
              },
              links: {
                self: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[size\]=10\z},
              }
            })
          end
        end

        context 'when there are sleep records from multiple followed users' do
          let(:followed_user1) { create(:user) }
          let(:followed_user2) { create(:user) }
          let(:user_not_followed) { create(:user) }

          let!(:sleep_record1) { create(:sleep_record, user: followed_user1, sleep_time: 5.minutes.ago, wake_time: Time.now) }
          let!(:sleep_record2) { create(:sleep_record, user: followed_user2, sleep_time: 10.minutes.ago, wake_time: Time.now) }
          let!(:sleep_record3) { create(:sleep_record, user: followed_user2, sleep_time: 20.minutes.ago, wake_time: Time.now, created_at: 1.week.ago - 10.minutes) }
          let!(:sleep_record4) { create(:sleep_record, user: user_not_followed, sleep_time: 30.minutes.ago, wake_time: Time.now) }

          before do
            user.follow(followed_user1)
            user.follow(followed_user2)
          end

          run_test! do
            expect(response_body[:data].first[:id]).to eq(sleep_record2.id.to_s) # Records with longer durations are ranked higher
            expect(response_body[:data].first[:attributes][:duration].to_i).to be > response_body[:data].second[:attributes][:duration].to_i

            # Doesn't include sleep record 3 because it's over 1 week ago
            # Doesn't include sleep record 4 because it's from a user not followed
            expect(response_body).to match({
              data: [
                {
                  id: sleep_record2.id.to_s,
                  type: 'sleepRecord',
                  attributes: {
                    wakeTime: sleep_record2.wake_time.as_json,
                    sleepTime: sleep_record2.sleep_time.as_json,
                    duration: TimeDifference.between(sleep_record2.wake_time, sleep_record2.sleep_time).humanize,
                  },
                  relationships: {
                    user: {
                      data: {
                        id: followed_user2.id.to_s,
                        type: 'user',
                      },
                    },
                  },
                },
                {
                  id: sleep_record1.id.to_s,
                  type: 'sleepRecord',
                  attributes: {
                    wakeTime: sleep_record1.wake_time.as_json,
                    sleepTime: sleep_record1.sleep_time.as_json,
                    duration: TimeDifference.between(sleep_record1.wake_time, sleep_record1.sleep_time).humanize,
                  },
                  relationships: {
                    user: {
                      data: {
                        id: followed_user1.id.to_s,
                        type: 'user',
                      },
                    },
                  },
                }
              ],
              meta: {
                total: 2,
                pages: 1,
              },
              links: {
                self: %r{\Ahttp?://[^/]+/users/#{user_id}\?page\[size\]=10\z},
              }
            })
          end
        end
      end
    end
  end
end
