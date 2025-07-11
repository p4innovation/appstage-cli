require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
  coverage_dir 'coverage'
end

require 'rubygems'
require 'bundler/setup'
require 'webmock/rspec'

Bundler.require

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'appstage'
require 'list_files'
require 'delete_files'
require 'upload_file'
require 'version'

RSpec.configure do |config|
  config.before(:each) do
    @original_stdout = $stdout
    $stdout = STDOUT
  end
  
  config.after(:each) do
    $stdout = @original_stdout if @original_stdout
  end
end


def mock_multipart_request(url, status, body)
    headers = { 'Content-Type' => /multipart\/form-data/ }

    match_multipart_body = ->(request) do
        request.body.force_encoding('BINARY')
        request.body =~ /testfile.txt/
    end

    stub_request(:post, url)
        .with(headers: headers, &match_multipart_body)
        .to_return(body: body.to_json, status: status)
end