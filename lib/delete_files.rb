module AppStage

  class DeleteFiles
    def initialize(options)
      @options = options
    end

    def execute
      begin
        files_json = ListFiles.new(@options).getFileList
        pattern = @options[:delete] || ".*"

        matching_files = files_json.select{|f| f['name'].match(/#{pattern}/)}
        puts "Deleting #{matching_files.count} files"

        matching_files.each do |rf|
          puts " deleting #{rf['name']}"
          #delete_file(rf['id'])
        end

      rescue Exception => e
        puts "Delete failed - #{e.message}"
        return 1
      end
      0
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
