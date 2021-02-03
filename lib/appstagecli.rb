#Appstage cli for uploading live builds
#Inspiration from https://cameronbothner.com/activestorage-beyond-rails-views/

require 'optparse'
require 'httparty'  #GEM
require 'mimemagic' #GEM
require 'digest'

module AppStage

  def self.execute
    options = {}

    option_parser = OptionParser.new do |parser|
      parser.banner = "Usage: appstagecli.rb [options]"

      parser.on("-h", "--help", "Show this help message") do ||
        puts parser
      end

      parser.on("-j", "--jwttoken JWT", "Your appstage.io account JWT token") do |v|
        options[:jwt] = v
      end

      parser.on("-p", "--project_id ID", "Your appstage.io project id") do |v|
        options[:project_id] = v
      end

      parser.on("-f", "--file FILENAME", "The file to upload") do |v|
        options[:filename] = v
      end

      parser.on("-h", "--host HOSTURL", "The appstage host, optional, leave blank to use live server") do |v|
        options[:host] = v
      end
    end

    option_parser.parse!

    if options[:filename].nil? || options[:jwt].nil? || options[:project_id].nil?
      puts option_parser.help
      exit 1
    end

    host = options[:host] or "https://appstage.io"
    file_path = File.expand_path(options[:filename])
    content_type = MimeMagic.by_path(file_path) || "application/octet-stream"
    file_contents = File.open(file_path).read
    token = options[:jwt]

    puts "Requesting direct upload..."

    json = {blob: {
              filename: File.basename(options[:filename]),
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
      # :debug_output => $stdout
      )

    puts "Finishing upload..."
    project_id = options[:project_id]
    cloud_stored_file = response_json['signed_id']

    json = {
      release_file: {
        cloud_stored_file: cloud_stored_file
      }
    }.to_json

    response = HTTParty.post(host+"/api/projects/#{project_id}/live_builds.json",
        :body => json,
        :headers => { 'Content-Type' => 'application/json',
                      'Authorization' => "Bearer #{token}"}
      )

    puts "all done!"
  end
end
