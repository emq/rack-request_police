# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/request_police/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-request_police"
  spec.version       = Rack::RequestPolice::VERSION
  spec.authors       = ["Rafal Wojsznis"]
  spec.email         = ["rafal.wojsznis@gmail.com"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency 'sinatra', '~> 1.4.5'
  spec.add_development_dependency 'rack-test', '~> 0.6.3'
  spec.add_development_dependency 'timecop', '~> 0.7.1'
  spec.add_development_dependency 'redis', '~> 3.2.0'
end
