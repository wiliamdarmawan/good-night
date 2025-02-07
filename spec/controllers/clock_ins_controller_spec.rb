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
      end
    end
  end
end
