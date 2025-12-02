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

def mock_direct_upload_flow(host, direct_upload_status: 200, direct_upload_body: nil, cdn_status: 200, release_status: 200, release_body: nil)
    cdn_url = "https://s3.amazonaws.com/test-bucket/uploads/test-key"
    signed_id = "test-signed-blob-id"

    direct_upload_body ||= {
        id: "abc123",
        key: "uploads/test-key",
        filename: "testfile.txt",
        content_type: "application/octet-stream",
        byte_size: 25,
        checksum: "ezoOjLlB7kqqMgQwtki3yQ==",
        signed_id: signed_id,
        direct_upload: {
            url: cdn_url,
            headers: {
                "Content-Type" => "application/octet-stream",
                "Content-MD5" => "ezoOjLlB7kqqMgQwtki3yQ=="
            }
        }
    }

    release_body ||= {
        id: "release-123",
        created_at: "2024-03-07T10:52:16.673Z"
    }

    stub_request(:post, "#{host}/api/direct_uploads")
        .to_return(body: direct_upload_body.to_json, status: direct_upload_status)

    stub_request(:put, cdn_url)
        .to_return(body: "", status: cdn_status)

    stub_request(:post, "#{host}/api/live_builds")
        .with(body: { signed_blob_id: signed_id }.to_json)
        .to_return(body: release_body.to_json, status: release_status)
end

def mock_direct_upload_error(host, status, error_message)
    stub_request(:post, "#{host}/api/direct_uploads")
        .to_return(body: { error: error_message }.to_json, status: status)
end