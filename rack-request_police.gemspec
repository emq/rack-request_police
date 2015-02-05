# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/request_police/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-request_police"
  spec.version       = Rack::RequestPolice::VERSION
  spec.authors       = ["Rafał Wojsznis"]
  spec.email         = ["rafal.wojsznis@gmail.com"]
  spec.summary = spec.description = "Rack middleware for logging selected request for further investigation / analyze."
  spec.homepage      = "https://github.com/emq/rack-request_police"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency 'sinatra', '~> 1.4.5'
  spec.add_development_dependency 'rack-test', '~> 0.6.3'
  spec.add_development_dependency 'timecop', '~> 0.7.1'
  spec.add_development_dependency 'redis', '~> 3.2.0'
  spec.add_development_dependency 'oj', '~> 2.11.4'
  spec.add_development_dependency 'coveralls', '~> 0.7.8'
  spec.add_development_dependency 'rack', '1.5.2' # show useful sinatra errors
end
