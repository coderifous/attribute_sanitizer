$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

Gem::Specification.new do |s|
  s.name = %q{attribute_sanitizer}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jim Garvin"]
  s.date = Time.now.strftime("%Y-%m-%d")
  s.email = %q{jim@thegarvin.com}
  s.files = Dir["[A-Z]*", "{lib,test}/**/*", "init.rb"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{DSL for sanitizing inputs.}
  s.description = %q{DSL for sanitizing inputs.}

  s.add_dependency "activesupport"
  s.add_dependency "i18n" # why doesn't activesupport have this as a dep?
  s.add_development_dependency "shoulda"
  s.add_development_dependency "mocha"

  # if s.respond_to? :specification_version
  #   s.specification_version = 3
  # end
end

