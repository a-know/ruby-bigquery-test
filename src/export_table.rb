require 'bundler/setup'
require 'google/api_client'
require 'yaml'
require 'json'

# export BigQuery table to Google Cloud Storage
# USAGE : ruby src/export_table.rb df-test-001:_0ed32dfe680c6b0634a2d8aa78fd3b270620f500.anonev_xzJPsRUruwN69f5rf_EvrMEPr1s export01.csv

def multipart_boundary
  'xxx'
end

# destination table id
dest_table_id = ARGV.shift

# export file name
export_file_name = ARGV.shift

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

dest_project_id = dest_table_id.split(':')[0]
dest_dataset_id = dest_table_id.split(':')[1].split('.')[0]
dest_table_id   = dest_table_id.split(':')[1].split('.')[1]

job_config = {
  'configuration' => {
    'extract' => {
      'sourceTable' => {
         'projectId' => dest_project_id,
         'datasetId' => dest_dataset_id,
         'tableId'   =>   dest_table_id
       },
      'destinationUris'   => ["gs://a-know-df-test/#{export_file_name}"],
      'destinationFormat' => 'CSV'
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
