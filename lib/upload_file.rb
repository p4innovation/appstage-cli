require 'faraday'
require 'faraday/multipart'
require 'faraday/httpclient'

module AppStage

  class UploadFile
    def initialize(options)
      @options = options
    end

    def execute
      begin
        host = @options[:host] || "https://appstage.io"
        file_path = File.expand_path(@options[:upload])
        content_type = MimeMagic.by_path(file_path) || "application/octet-stream"
        file_contents = File.open(file_path).read
        filename = File.basename(@options[:upload])
        token = @options[:jwt]

        puts "Uploading #{filename} #{File.size(file_path)} bytes..."

        json = {blob: {
                  filename: filename,
                  byte_size: File.size(file_path),
                  content_type: content_type,
                  checksum: Digest::MD5.base64digest(file_contents)
               }}.to_json

        response = HTTParty.post(host+'/api/direct_uploads',
            :body => json,
            :headers => { 'Content-Type' => 'application/json',
                          'Authorization' => "Bearer #{token}"}
          )

        response_json = JSON.parse(response.body)

        direct_url = response_json['direct_upload']['url']
        headers = response_json['direct_upload']['headers']
        headers['Connection'] = 'keep-alive'

        conn = Faraday.new(url: direct_url, headers: headers) do |f|
          f.request :multipart
          f.adapter :httpclient
        end

        direct_response = conn.put('') do |req|
          req.options.timeout = 5000
          req.body =  file_contents
        end

        cloud_stored_file = response_json['signed_id']

        json = {
          release_file: {
            cloud_stored_file: cloud_stored_file
          }
        }.to_json

        response = HTTParty.post(host+"/api/live_builds.json",
            :body => json,
            :headers => { 'Content-Type' => 'application/json',
                          'Authorization' => "Bearer #{token}"}
          )

        puts "Upload complete"
        response.code == 200 ? 0 : response.code
      rescue Exception => e
        puts "Upload failed - #{e}"
        0
      end
    end
  end
end
