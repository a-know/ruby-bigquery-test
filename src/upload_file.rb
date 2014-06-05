require 'bundler/setup'
require 'rubygems'
require 'fog'
require 'yaml'

# load credential yaml
credential_yaml = YAML.load_file('.gcs-credential.yaml')

# create a connection
connection = Fog::Storage.new({
  :provider                         => 'Google',
  :google_storage_access_key_id     => credential_yaml['google_storage_access_key_id'],
  :google_storage_secret_access_key => credential_yaml['google_storage_secret_access_key'],
})

# First, a place to contain the glorious details
directory = connection.directories.create(
  :key    => "fog-demo-#{Time.now.to_i}", # globally unique name
)

# list directories
p connection.directories

# upload that resume
file = directory.files.create(
  :key    => 'resume.html',
  :body   => File.open("/path/to/my/resume.html"),
)

# # あるバケットの中を参照
# directory = connection.directories.get("a-know-df-test")

# p directory
# p directory.files