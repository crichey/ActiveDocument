version = File.read(File.expand_path("../ACTIVE_DOCUMENT_VERSION",__FILE__)).strip
SPEC = Gem::Specification.new do |s|
  s.name = 'ActiveDocument'
  s.version = version
  s.summary = "Object Mapper for XML Database"
  s.description = %{Object Mapper for XML Database. Initially setup for connection to MarkLogic}
  s.files = Dir['lib/**/*.rb']
  s.require_path = 'lib'
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.author = "Clark D. Richey, Jr."
  s.email = "clark@clarkrichey.com"
  s.homepage = "http://github.com/crichey/ActiveDocument"
  s.add_dependency("nokogiri", ">=1.4.1")
end