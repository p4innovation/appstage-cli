Gem::Specification.new do |s|
  s.name      = 'appstage'
  s.version   = '0.0.5'
  s.platform  = Gem::Platform::RUBY
  s.summary   = 'Appstage.io CLI gem'
  s.description = "Allows upload and control of the live stage content"
  s.authors   = ['P4 Innovation Ltd']
  s.email     = ['appstage@p4innovation.com']
  s.homepage  = 'http://p4.io'
  s.license   = 'MIT'
  s.files     = ['lib/appstage.rb', 'lib/list_files.rb', 'lib/upload_file.rb', 'lib/delete_files.rb']
  s.executables = ['appstage']
  s.require_path = 'lib'
  s.add_dependency 'httparty', '~>0.18.1'
  s.add_dependency 'mimemagic', '~>0.3.5'
  s.add_dependency 'faraday', '~>2.3.0'
  s.add_dependency 'faraday-multipart', '~>1.0.4'
  s.add_dependency 'faraday-httpclient', '~> 2.0'
end
