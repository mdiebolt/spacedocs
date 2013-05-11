# -*- encoding: utf-8 -*-
require File.expand_path('../lib/spacedocs/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Matt Diebolt"]
  gem.email         = ["mdiebolt@gmail.com"]
  gem.description   = %q{Generates beautiful API docs based on JSON output from the Node project dox. Supports jsDocToolkit comment style}
  gem.summary       = %q{Documentation from space}
  gem.homepage      = "http://mdiebolt.github.com/spacedocs"

  gem.files         = Dir.glob("{lib}/**/*") + %w(README.md)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "spacedocs"
  gem.require_paths = ["lib"]
  gem.version       = Spacedocs::VERSION

  gem.add_dependency 'compass'
  gem.add_dependency 'haml'
  gem.add_dependency 'rake'
  gem.add_dependency 'sass'
  gem.add_dependency 'tilt'
end
