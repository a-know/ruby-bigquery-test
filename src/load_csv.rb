require 'bundler/setup'
require 'google/api_client'
require 'google/api_client/client_secrets'

# Initialize the client.
client = Google::APIClient.new(
  :application_name => 'Example Ruby Bigquery',
  :application_version => '1.0.0'
)

# Initialize Bigquery client.
bq_client = client.discovered_api('bigquery', 'v2')

p bq_client