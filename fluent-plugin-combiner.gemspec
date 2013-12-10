# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-combiner"
  spec.version       = "0.0.1"
  spec.authors       = ["karahiyo"]
  spec.email         = ["a.ryuklnm@gmail.com"]
  spec.summary       = "Combine buffer output data to cut-down net-i/o load"
  spec.description   = "Combine buffer output data to cut-down net-i/o load"
  spec.homepage      = "https://github.com/karahiyo/fluent-plugin-combiner"

  spec.rubyforge_project = "fluent-plugin-combiner"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "fluentd"
end
