require 'json'

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
        0
      rescue Exception => e
        puts "File listing failed - #{e.message}"
        -1
      end
    end

    def getFileList
      host = @options[:host] || "https://www.appstage.io"
      raise('Invalid project token') unless @options[:jwt]
      token = @options[:jwt]
      pattern = @options[:list].nil? ? ".*" : @options[:list]

      response = HTTParty.get(host+"/api/live_builds",
          :headers => { 'Content-Type' => 'application/json',
                        'Authorization' => "Bearer #{token}"}
      )
      raise(JSON.parse(response.body)['error']) unless response.code == 200
      files = JSON.parse(response.body)['release_files'].select{|f| f['name'].match(/#{pattern}/)}
    end
  end

end
