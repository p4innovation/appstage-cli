module AppStage

class ListFiles
  def initialize(options)
    @options = options
  end

  def execute
    puts @options
    host = @options[:host] || "https://appstage.io"
    token = @options[:jwt]
    pattern = @options[:list].nil? ? ".*" : Regexp.escape(@options[:list])

    response = HTTParty.get(host+"/api/live_builds.json",
        :headers => { 'Content-Type' => 'application/json',
                      'Authorization' => "Bearer #{token}"}
    )
    puts response.body
    files_json = JSON.parse(response.body)['release_files'].select{|f| f['name'].match(/#{pattern}/)}

    return files_json
  end
end

end
