# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scrawls/version'

Gem::Specification.new do |spec|
  spec.name          = "scrawls"
  spec.version       = Scrawls::VERSION
  spec.authors       = ["Kirk Haines"]
  spec.email         = ["wyhaines@gmail.com"]

  spec.summary       = %q{Scrawls is a simple ruby web server with a pluggable architecture.}
  spec.description   = %q{Scrawls is a web server, written in Ruby, that lets one choose what sort of concurreny engine to use, as well as the HTTP parsing engine to use. }
  spec.homepage      = "http://github.com/wyhaines/scrawls"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_runtime_dependency "mime-types", "~> 3.0"
end
