module AppStage

  class DeleteFiles
    def initialize(options)
      @options = options
    end

    def execute
      files_json = ListFiles.new(@options).execute
      pattern = @options[:delete].nil? ? "*.*" : Regexp.escape(@options[:delete])
      
      puts files_json
      puts pattern

      matching_files = files_json.select{|f| f['name'].match(/#{pattern}/)}
      puts "Deleting #{matching_files.count} files"

      matching_files.each do |rf|
        puts " deleting #{rf['name']}"
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
