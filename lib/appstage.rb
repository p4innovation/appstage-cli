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
      parser.banner = "Usage: appstage <command> [options]"

      parser.separator " Commands:-"

      parser.on("-u", "--upload [PATTERN]", "Upload a file to the live build release") do |c|
        options[:upload] = c
      end

      parser.on("-d", "--delete [PATTERN]", "Delete a file to the live build release") do |c|
        options[:delete] = c
      end

      parser.on("-l", "--list [PATTERN]", "Lists files the live build release") do |c|
        options[:list] = c
      end

      parser.on("-h", "--help", "Show this help message") do ||
        puts parser
      end

      parser.separator " Options:-"

      parser.on("-j", "--jwttoken JWT", "Your appstage.io account JWT token") do |v|
        options[:jwt] = v
      end

      parser.on("-p", "--project_id ID", "Your appstage.io project id") do |v|
        options[:project_id] = v
      end

      parser.on("-h", "--host HOSTURL", "The appstage host, optional, leave blank to use live server") do |v|
        options[:host] = v
      end
    end

    begin
      option_parser.parse!
    rescue Exception => e
      puts "Invalid invocation - #{e.message}"
      puts option_parser.help
      exit 1
    end

    if !options.key?(:upload) && !options.key?(:delete) && !options.key?(:list)
      puts option_parser.help
      exit 1
    end

    if options.key?(:list)
      exit ListFiles.new(options).execute
    end

    if options.key?(:delete)
      exit DeleteFiles.new(options).execute
    end

    if options.key?(:upload)
      exit UploadFile.new(options).execute
    end
  end
end
