module AppStage

class ListFiles
  def initialize(options)
    @options = options
  end

  def execute
    host = @options[:host] or "https://appstage.io"
    token = @options[:jwt]

    response = HTTParty.get(host+"/api/live_builds.json",
        :headers => { 'Content-Type' => 'application/json',
                      'Authorization' => "Bearer #{token}"}
    )
    files_json = JSON.parse(response.body)

    return files_json
  end
end

end
