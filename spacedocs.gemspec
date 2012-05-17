# -*- encoding: utf-8 -*-
require File.expand_path('../lib/spacedocs/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Matt Diebolt"]
  gem.email         = ["mdiebolt@gmail.com"]
  gem.description   = %q{Generates beautiful API docs based on JSON output from the Node project dox. Supports jsDocToolkit comment style}
  gem.summary       = %q{Documentation from space}
  gem.homepage      = "http://mdiebolt.github.com/spacedocs"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "spacedocs"
  gem.require_paths = ["lib"]
  gem.version       = Spacedocs::VERSION
end
