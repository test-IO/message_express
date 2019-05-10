lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'message_express/version'

Gem::Specification.new do |spec|
  spec.name          = 'message_express'
  spec.version       = MessageExpress::VERSION
  spec.authors       = ['test IO']
  spec.email         = ['devs@test.io']

  spec.summary       = 'Framework helping message communication between ruby services'
  spec.homepage      = 'https://github.com/test-IO/message_express'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
