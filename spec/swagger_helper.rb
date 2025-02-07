# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.json' => {
      openapi: '3.0.1',
      info: {
        title: 'Good Night API',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'localhost:3000'
            }
          }
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :json

  # auto-generating response examples into swagger.json file
  # reference: https://github.com/rswag/rswag/issues/651
  config.after do |example|
    next unless example.metadata[:rswag]

    summary = example.metadata[:example_group][:description]
    # save the response body as example
    content = example.metadata[:response][:content] || {}

    value = JSON.parse(response.body, symbolize_names: true) if response.body.present?

    example_spec = {
      'application/json' => {
        examples: {
          "#{summary}": {
            value: value
          }
        }
      }
    }
    example.metadata[:response][:content] = content.deep_merge(example_spec) unless value.nil?
    next unless example.metadata[:operation][:parameters]

    # save the request payload as example
    example.metadata[:operation][:parameters].each.with_index do |param, i|
      value = send(param[:name])
      name = summary

      if param[:in] == :body
        # parameters in body require to be added to request_examples
        example.metadata[:operation][:request_examples] ||= []
        example.metadata[:operation][:request_examples] << { value: value, summary: summary, name: name }
      else
        # parameters in query, path, headers, etc.... require to be added to examples
        example.metadata[:operation][:parameters][i][:examples] ||= {}
        example.metadata[:operation][:parameters][i][:examples][name] = { value: value }
      end
    end
  end
end
