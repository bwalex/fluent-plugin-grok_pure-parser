# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-grok_pure-parser"
  spec.version       = File.read("VERSION").strip
  spec.authors       = ["Alex Hornung"]
  spec.email         = ["alex@alexhornung.com"]
  spec.description   = "This plugin uses jls-grok under the hood which allows you to use the full range of grok patterns."
  spec.summary       = %q{fluentd parser plugin to be able to use Grok patterns}
  spec.homepage      = "https://github.com/bwalex/fluent-plugin-grok_pure-parser"
  spec.license       = "MIT"
  spec.has_rdoc      = false

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "jls-grok", "~> 0.11.0"
  spec.add_dependency "fluentd", "~> 0.10.17"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.4.2"
end
