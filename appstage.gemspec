Gem::Specification.new do |s|
  s.name      = 'appstage'
  s.version   = '0.0.1'
  s.platform  = Gem::Platform::RUBY
  s.summary   = 'Appstage.io CLI gem'
  s.description = "Allows upload and control of the live stage content"
  s.authors   = ['P4 Innovation Ltd']
  s.email     = ['appstage@p4innovation.com']
  s.homepage  = 'http://p4.io'
  s.license   = 'MIT'
  s.files     = Dir.glob("{lib,bin}/**/*") # This includes all files under the lib directory recursively, so we don't have to add each one individually.
  s.executables = ['appstage']
  s.require_path = 'lib'
end
