require 'bundler/setup'
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
# credential = File.read('client_secrets.txt').split(',')
credential = Google::APIClient::ClientSecrets.load
 
 
flow = Google::APIClient::InstalledAppFlow.new(
  :client_id => credential.client_id,
  :client_secret => credential.client_secret,
  :scope => ['https://www.googleapis.com/auth/bigquery']
)
client.authorization = flow.authorize
 
p client.authorization