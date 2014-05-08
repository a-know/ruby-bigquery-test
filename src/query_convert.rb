# encoding: utf-8

require 'bundler/setup'
require 'google/api_client'
require 'yaml'
require 'json'

def multipart_boundary
  'xxx'
end

def query
  <<"EOS"
SELECT CASE
WHEN df_test.sample.price <= 100 THEN '小'
WHEN df_test.sample.price <= 200 THEN '中'
WHEN df_test.sample.price <= 300 THEN '大'
ELSE '' END price_class,
df_test.sample.id, df_test.sample.price, df_test.sample.name + 'さん' FROM [df_test.sample] LIMIT 1000
EOS
end

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

job_config = {
  'configuration' => {
    'query' => {
      'kind' => 'bigquery#queryRequest',
      'query' => query,
      'maxResults' => 1,
      "defaultDataset" => {
        "datasetId" => 'df_test',
        "projectId" => 'df-test-001'
      },
      "timeoutMs" => 10000,
      "dryRun" => false,
      "preserveNulls" => false,
      "useQueryCache" => false
    }
  }
}

body = "--#{multipart_boundary}\n"
body += "Content-Type: application/json; charset=UTF-8\n"
body += "\n"
body += "#{job_config.to_json}\n"
body += "--#{multipart_boundary}--\n"

# Make an API call.
result = client.execute(
  :api_method => bq_client.jobs.insert,
  :parameters => {
    'projectId' => '234230709110'
  },
  :body => body,
  :headers => { 'Content-Type' => "multipart/related; boundary=#{multipart_boundary}" }
)


puts result.data
puts result.response.body