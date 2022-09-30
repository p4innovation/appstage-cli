module AppStage

  class ListFiles
    def initialize(options)
      @options = options
    end

    def execute
      begin
        getFileList.each do |rf|
          puts "#{rf['name']}"
        end
      rescue Exception => e
        puts "File listing failed - #{e.message}"
        return 1
      end
      0
    end

    def getFileList
      host = @options[:host] || "https://www.appstage.io"
      token = @options[:jwt]
      pattern = @options[:list].nil? ? ".*" : Regexp.escape(@options[:list])

      response = HTTParty.get(host+"/api/live_builds.json",
          :headers => { 'Content-Type' => 'application/json',
                        'Authorization' => "Bearer #{token}"}
      )
      raise "Server error #{response.code}" if response.code != 200
      files = JSON.parse(response.body)['release_files'].select{|f| f['name'].match(/#{pattern}/)}
    end
  end

end
