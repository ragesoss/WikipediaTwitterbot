# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wikipedia_twitterbot/version'

Gem::Specification.new do |spec|
  spec.name          = 'wikipedia_twitterbot'
  spec.version       = WikipediaTwitterbot::VERSION
  spec.authors       = ['Sage Ross']
  spec.email         = ['sage@ragesoss.com']

  spec.summary       = 'Tools for building Wikipedia-focused Twitter bots'
  spec.homepage      = 'https://github.com/ragesoss/WikipediaTwitterbot'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_runtime_dependency 'sqlite3'
  spec.add_runtime_dependency 'activerecord'
  spec.add_runtime_dependency 'activerecord-import'
  spec.add_runtime_dependency 'twitter'
  spec.add_runtime_dependency 'mediawiki_api'
  spec.add_runtime_dependency 'logger'
end
