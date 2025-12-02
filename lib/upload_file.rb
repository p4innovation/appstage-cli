require 'json'
require 'digest'
require 'base64'

module AppStage

  class UploadFile
    def initialize(options)
      @options = options
    end

    def execute
      begin
        host = @options[:host] || "https://www.appstage.io"

        raise('No file specified') unless @options[:upload]
        file_path = File.expand_path(@options[:upload])
        filename = File.basename(@options[:upload])

        raise('Invalid project token') unless @options[:jwt]
        token = @options[:jwt]

        file_size = File.size(file_path)
        puts "Uploading #{filename} #{file_size} bytes..."

        checksum = calculate_checksum(file_path)

        direct_upload_response = request_direct_upload(host, token, filename, file_size, checksum)
        upload_to_cdn(file_path, direct_upload_response)
        create_release_file(host, token, direct_upload_response['signed_id'])

        puts "Upload complete"
        0
      rescue Exception => e
        puts "Upload failed - #{e}"
        -1
      end
    end

    private

    def calculate_checksum(file_path)
      Base64.strict_encode64(Digest::MD5.file(file_path).digest)
    end

    def request_direct_upload(host, token, filename, byte_size, checksum)
      response = HTTParty.post(
        "#{host}/api/direct_uploads",
        body: {
          blob: {
            filename: filename,
            byte_size: byte_size,
            checksum: checksum,
            content_type: 'application/octet-stream'
          }
        }.to_json,
        headers: {
          'Authorization' => "Bearer #{token}",
          'Content-Type' => 'application/json'
        },
        verify: false
      )

      raise(JSON.parse(response.body)['error']) unless response.code == 200
      JSON.parse(response.body)
    end

    def upload_to_cdn(file_path, direct_upload_data)
      url = direct_upload_data['direct_upload']['url']
      headers = direct_upload_data['direct_upload']['headers']

      response = HTTParty.put(
        url,
        body: File.read(file_path),
        headers: headers,
        verify: false
      )

      raise("CDN upload failed with status #{response.code}") unless [200, 204].include?(response.code)
    end

    def create_release_file(host, token, signed_blob_id)
      response = HTTParty.post(
        "#{host}/api/live_builds",
        body: {
          signed_blob_id: signed_blob_id
        }.to_json,
        headers: {
          'Authorization' => "Bearer #{token}",
          'Content-Type' => 'application/json'
        },
        verify: false
      )

      raise(JSON.parse(response.body)['error']) unless response.code == 200
    end
  end
end
