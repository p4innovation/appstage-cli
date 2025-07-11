require 'json'

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

        puts "Uploading #{filename} #{File.size(file_path)} bytes..."

        json = {
          release_file: {
            cloud_stored_file: File.open(file_path)
          }
        }

        response = HTTParty.post(host+"/api/live_builds",
          :body => json,
          :multipart => true,
          :headers => {
            'Authorization' => "Bearer #{token}"
          },
          :verify => false
        )
        raise(JSON.parse(response.body)['error']) unless response.code == 200

        puts "Upload complete"
        0
      rescue Exception => e
        puts "Upload failed - #{e}"
        -1
      end
    end
  end
end
