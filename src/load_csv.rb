require 'bundler/setup'
require 'google/api_client'
require 'yaml'

# load credential yaml
oauth_yaml = YAML.load_file('.google-api.yaml')

# Initialize the client.
client = Google::APIClient.new(
  :application_name => 'Example Ruby Bigquery',
  :application_version => '1.0.0')
client.authorization.client_id = oauth_yaml["client_id"]
client.authorization.client_secret = oauth_yaml["client_secret"]
client.authorization.scope = oauth_yaml["scope"]
client.authorization.refresh_token = oauth_yaml["refresh_token"]
client.authorization.access_token = oauth_yaml["access_token"]

# Initialize Bigquery client.
bq_client = client.discovered_api('bigquery', 'v2')

p bq_client