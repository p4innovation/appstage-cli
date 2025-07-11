require File.expand_path("../lib/version", __FILE__)

Gem::Specification.new do |s|
  s.name      = 'appstage'
  s.version   = Appstage::VERSION
  s.platform  = Gem::Platform::RUBY
  s.summary   = 'Appstage.io CLI gem'
  s.description = "List, Upload and Delete live build content on appstage.io"
  s.authors   = ['P4 Innovation Ltd']
  s.email     = ['hello@appstage.io']
  s.homepage  = 'https://github.com/p4innovation/appstage-cli'
  s.license   = 'MIT'
  s.files     = ['lib/appstage.rb', 'lib/list_files.rb', 'lib/upload_file.rb', 'lib/delete_files.rb', 'lib/version.rb']
  s.executables = ['appstage']
  s.require_path = 'lib'
  s.required_ruby_version = '>= 3.1.0'
  s.add_dependency 'httparty', '~>0.21'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.6'
  s.add_development_dependency 'webmock', '~> 3.23'
end
