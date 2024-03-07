require 'rubygems'
require 'bundler/setup'
require 'webmock/rspec'

Bundler.require

RSpec.configure do |config|
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