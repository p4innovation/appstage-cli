module AppStage

  class UploadFile
    def initialize(options)
      @options = options
    end

    def execute
      host = @options[:host] or "https://appstage.io"
      file_path = File.expand_path(@options[:filename])
      content_type = MimeMagic.by_path(file_path) || "application/octet-stream"
      file_contents = File.open(file_path).read
      token = @options[:jwt]

      puts "Requesting direct upload..."

      json = {blob: {
                filename: File.basename(@options[:filename]),
                byte_size: file_contents.size,
                content_type: content_type,
                checksum: Digest::MD5.base64digest(file_contents)
             }}.to_json

      response = HTTParty.post(host+'/api/direct_uploads',
          :body => json,
          :headers => { 'Content-Type' => 'application/json',
                        'Authorization' => "Bearer #{token}"}
        )

      response_json = JSON.parse(response.body)

      puts "Uploading #{file_contents.size/1024}Kb file to appstage..."
      direct_url = response_json['direct_upload']['url']
      headers = response_json['direct_upload']['headers']
      headers['Content-Type' => 'application/json']

      direct_response = HTTParty.put(direct_url,
          :body => file_contents,
          :headers => headers
          #,:debug_output => $stdout
        )

      puts "Finishing upload..."
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
          #,:debug_output => $stdout
        )

      response.code == 200 ? 0 : response.code
    end
  end
end
