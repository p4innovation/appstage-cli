module AppStage

class ListFiles
  def initialize(options)
    @options = options
  end

  def execute
    puts "listing files"
    host = @options[:host] or "https://appstage.io"
    token = @options[:jwt]

    puts @options
    puts @options[:host]
    puts host

    response = HTTParty.get(host+"/api/live_builds.json",
        :headers => { 'Content-Type' => 'application/json',
                      'Authorization' => "Bearer #{token}"}
    )
    puts response.body
    response_json = JSON.parse(response.body)

    response_json['release_files'].each do |rf|
      puts rf['name']
    end
    return 0
  end
end

end
