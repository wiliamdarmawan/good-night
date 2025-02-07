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

      response(200, 'get user clock in logs') do
        context "when there isn't any clock in logs" do
          run_test! do
            expect(response_body).to match(
              {
                data: [],
                meta: {
                  total: 0,
                  pages: 1
                },
                links: {
                  self: %r{\Ahttp?://[^/]+/users/#{user_id}/clock-ins\?page\[size\]=10\z}
                }
              }
            )
          end
        end

        context 'when clock ins log exists & no pagination params given' do
          before { (1..15).map { |i| create(:clock_in, user: user, created_at: Time.now - i.hours) } }

          run_test! do
            expect(response_body[:data].count).to eq(10)
            expect(Time.parse(response_body[:data].first[:attributes][:createdAt])).to be > Time.parse(response_body[:data].second[:attributes][:createdAt])
            expect(response_body[:data]).to all(include(:id, :type, :attributes, :relationships))
            expect(response_body[:meta]).to match(
              {
                total: 15,
                pages: 2
              }
            )
            expect(response_body[:links]).to match(
              {
                self: %r{\Ahttp?://[^/]+/users/#{user_id}/clock-ins\?page\[size\]=10\z},
                next: %r{\Ahttp?://[^/]+/users/#{user_id}/clock-ins\?page\[number\]=2&page\[size\]=10\z},
                last: %r{\Ahttp?://[^/]+/users/#{user_id}/clock-ins\?page\[number\]=2&page\[size\]=10\z}
              }
            )
          end
        end

        context 'when clock ins log exists & pagination params number given' do
          before { (1..25).map { |i| create(:clock_in, user: user, created_at: Time.now - i.hours) } }

          let(:pagination_params) do
            {
              page: {
                number: 2
              }
            }
          end

          run_test! do
            expect(response_body[:data].count).to eq(10)
            expect(Time.parse(response_body[:data].first[:attributes][:createdAt])).to be > Time.parse(response_body[:data].second[:attributes][:createdAt])
            expect(response_body[:data]).to all(include(:id, :type, :attributes, :relationships))
            expect(response_body[:meta]).to match(
              {
                total: 25,
                pages: 3
              }
            )
            expect(response_body[:links]).to match(
              {
                first: %r{\Ahttp?://[^/]+/users/#{user_id}/clock-ins\?page\[size\]=10\z},
                prev: %r{\Ahttp?://[^/]+/users/#{user_id}/clock-ins\?page\[size\]=10\z},
                self: %r{\Ahttp?://[^/]+/users/#{user_id}/clock-ins\?page\[number\]=2&page\[size\]=10\z},
                next: %r{\Ahttp?://[^/]+/users/#{user_id}/clock-ins\?page\[number\]=3&page\[size\]=10\z},
                last: %r{\Ahttp?://[^/]+/users/#{user_id}/clock-ins\?page\[number\]=3&page\[size\]=10\z}
              }
            )
          end
        end

        context 'when clock in logs exists & pagination params size given' do
          before { (1..25).map { |i| create(:clock_in, user: user, created_at: Time.now - i.hours) } }

          let(:pagination_params) do
            {
              page: {
                size: 30,
              }
            }
          end

          run_test! do
            expect(response_body[:data].count).to eq(25)
            expect(Time.parse(response_body[:data].first[:attributes][:createdAt])).to be > Time.parse(response_body[:data].second[:attributes][:createdAt])
            expect(response_body[:data]).to all(include(:id, :type, :attributes, :relationships))
            expect(response_body[:meta]).to match(
              {
                total: 25,
                pages: 1
              }
            )
            expect(response_body[:links]).to match(
              {
                self: %r{\Ahttp?://[^/]+/users/#{user_id}/clock-ins\?page\[size\]=30\z},
              }
            )
          end
        end

        context 'when clock in logs exists & pagination params number & size given' do
          before { (1..25).map { |i| create(:clock_in, user: user, created_at: Time.now - i.hours) } }

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
            expect(Time.parse(response_body[:data].first[:attributes][:createdAt])).to be > Time.parse(response_body[:data].second[:attributes][:createdAt])
            expect(response_body[:data]).to all(include(:id, :type, :attributes, :relationships))
            expect(response_body[:meta]).to match(
              {
                total: 25,
                pages: 5
              }
            )
            expect(response_body[:links]).to match(
              {
                first: %r{\Ahttp?://[^/]+/users/#{user_id}/clock-ins\?page\[size\]=5\z},
                prev: %r{\Ahttp?://[^/]+/users/#{user_id}/clock-ins\?page\[size\]=5\z},
                self: %r{\Ahttp?://[^/]+/users/#{user_id}/clock-ins\?page\[number\]=2&page\[size\]=5\z},
                next: %r{\Ahttp?://[^/]+/users/#{user_id}/clock-ins\?page\[number\]=3&page\[size\]=5\z},
                last: %r{\Ahttp?://[^/]+/users/#{user_id}/clock-ins\?page\[number\]=5&page\[size\]=5\z}
              }
            )
          end
        end

        context 'when there is only one record' do
          let!(:clock_in) { create(:clock_in, user: user) }

          run_test! do
            expect(response_body).to match({
              data: [
                {
                  id: clock_in.id.to_s,
                  type: 'clockIn',
                  attributes: {
                    createdAt: clock_in.created_at.as_json,
                    type: clock_in.clock_in_type,
                  },
                  relationships: {},
                }
              ],
              meta: {
                total: 1,
                pages: 1,
              },
              links: {
                self: %r{\Ahttp?://[^/]+/users/#{user_id}/clock-ins\?page\[size\]=10\z},
              }
            })
          end
        end
      end
    end
  end

  path '/users/{user_id}/clock-ins/sleep' do
    parameter name: 'user_id', in: :path, type: :string, description: 'user_id'

    post('logs user sleep time') do
      tags 'Sleep'
      consumes 'application/json'

      response(400, 'Invalid params') do
        context 'when user is sleeping' do
          let!(:clock_in) { create(:clock_in, user: user, clock_in_type: :sleep) }

          run_test! do
            expect(response_body).to match(
              {
                errors: [
                  {
                    error: 'User is sleeping',
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
      end

      response(201, 'successfully sleeps') do
        context 'when user has not sleep yet' do
          run_test! do
            clock_in = user.clock_ins.last

            expect(response_body).to match(
              {
                data: {
                  id: clock_in.id.to_s,
                  type: 'clockIn',
                  attributes: {
                    createdAt: clock_in.created_at.as_json,
                    type: 'sleep',
                  },
                  relationships: {
                    user: {
                      data: {
                        id: clock_in.user.id.to_s,
                        type: 'user',
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

  path '/users/{user_id}/clock-ins/wake' do
    parameter name: 'user_id', in: :path, type: :string, description: 'user_id'

    post('logs user wake up time') do
      tags 'Wake Up'
      consumes 'application/json'

      response(400, 'Invalid params') do
        context 'when user has already woken up before' do
          let!(:clock_in) { create(:clock_in, user: user, clock_in_type: :wake) }

          run_test! do
            expect(response_body).to match(
              {
                errors: [
                  {
                    error: 'User has already woken up',
                    errorCode: 'GN-1',
                    errorHandling: "Please ensure you've entered the correct parameters"
                  }
                ]
              }
            )
          end
        end

        context "when user hasn't slept yet" do
          run_test! do
            expect(response_body).to match(
              {
                errors: [
                  {
                    error: "User hasn't slept yet",
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

      response(201, 'successfully wake up') do
        context 'when user has sleep and not woke up yet' do
          let!(:sleep_time) { create(:clock_in, user: user, clock_in_type: :sleep, created_at: 1.day.ago) }

          run_test! do
            wake_time = user.clock_ins.last
            sleep_record = SleepRecord.where(user: user).last

            expect(response_body).to match(
              {
                data: {
                  id: wake_time.id.to_s,
                  type: 'clockIn',
                  attributes: {
                    createdAt: wake_time.created_at.as_json,
                    type: 'wake',
                  },
                  relationships: {
                    user: {
                      data: {
                        id: wake_time.user.id.to_s,
                        type: 'user',
                      }
                    }
                  }
                }
              }
            )
            expect(sleep_record.wake_time).to eq(wake_time.created_at)
            expect(sleep_record.sleep_time).to eq(sleep_time.created_at)
          end
        end
      end
    end
  end
end
