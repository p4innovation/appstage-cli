Gem::Specification.new do |s|
  s.name      = 'appstage'
  s.version   = '0.0.9'
  s.platform  = Gem::Platform::RUBY
  s.summary   = 'Appstage.io CLI gem'
  s.description = "List, Upload and Delete live build content on appstage.io"
  s.authors   = ['P4 Innovation Ltd']
  s.email     = ['hello@appstage.io']
  s.homepage  = 'https://github.com/p4innovation/appstage-cli'
  s.license   = 'MIT'
  s.files     = ['lib/appstage.rb', 'lib/list_files.rb', 'lib/upload_file.rb', 'lib/delete_files.rb']
  s.executables = ['appstage']
  s.require_path = 'lib'
  s.add_dependency 'httparty', '~>0.18.1'
  s.add_dependency 'mimemagic', '~>0.3.5'
end
