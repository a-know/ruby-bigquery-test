require 'bundler/setup'
require 'yaml'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
 
# Initialize the client.
client = Google::APIClient.new(
  :application_name => 'Example Ruby Bigquery',
  :application_version => '1.0.0'
)
 
# Run installed application flow. Check the samples for a more
# complete example that saves the credentials between runs.
credential = Google::APIClient::ClientSecrets.load
 
 
flow = Google::APIClient::InstalledAppFlow.new(
  :client_id => credential.client_id,
  :client_secret => credential.client_secret,
  :scope => ['https://www.googleapis.com/auth/bigquery']
)
client.authorization = flow.authorize
 
p client.authorization

yml = {}.tap do |y|
  y['mechanism']     = 'oauth_2'
  y['scope']         = client.authorization.scope
  y['client_id']     = client.authorization.client_id
  y['client_secret'] = client.authorization.client_secret
  y['access_token']  = client.authorization.access_token
  y['refresh_token'] = client.authorization.refresh_token
end

open('.google-api.yaml','w') do |f|
  YAML.dump(yml,f)
end