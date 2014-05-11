require 'bundler/setup'
require 'google/api_client'
require 'yaml'
require 'json'

def multipart_boundary
  'xxx'
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
    'load' => {
      'sourceUris' => ['gs://a-know-df-test/sample.csv'],
      'schema' => {
        'fields' => [
          {
            'name' => 'id',
            'type' => 'INTEGER'
          },
          {
            'name' => 'name',
            'type' => 'STRING'
          },
          {
            'name' => 'price',
            'type' => 'INTEGER'
          },
        ]
      },
      'destinationTable' => {
        'projectId' => 'df-test-001',
        'datasetId' => 'df_test',
        'tableId'   => 'sample'
      },
      'createDisposition' => 'CREATE_NEVER',
      'writeDisposition' => 'WRITE_APPEND'
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
    'projectId' => '234230709110',
    'uploadType' => 'multipart'
  },
  :body => body,
  :headers => { 'Content-Type' => "multipart/related; boundary=#{multipart_boundary}" }
)

puts result.response.body

while(true) do
  res = JSON.parse(result.response.body)
  p state = res['status']['state']
  break if state == 'DONE'

  result = client.execute(
    :api_method => bq_client.jobs.get,
    :parameters => {
      'projectId' => '234230709110',
      'jobId' => res['jobReference']['jobId']
    }
  )
  sleep(10)
end

puts result.response.body