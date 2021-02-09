module AppStage

  class DeleteFiles
    def initialize(options)
      @options = options
    end

    def execute
      files_json = ListFiles.new(@options).execute

      files_json['release_files'].each do |rf|
        puts "deleting #{rf['name']}"
        delete_file(rf['id'])
      end

      return 0
    end

  private

    def delete_file(file_id)
      host = @options[:host] or "https://appstage.io"
      token = @options[:jwt]
      response = HTTParty.delete(host+"/api/live_builds/#{file_id}.json",
          :headers => { 'Content-Type' => 'application/json',
                        'Authorization' => "Bearer #{token}"}
      )
    end

  end

end
