# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "fluent-plugin-gcloud-pubsub-custom"
  gem.description = "Google Cloud Pub/Sub input/output plugin for Fluentd event collector with universe_domain parameter"
  gem.license     = "MIT"
  gem.homepage    = "https://github.com/theoberthier/fluent-plugin-gcloud-pubsub-custom"
  gem.summary     = gem.description
  gem.version     = "2.0.0"
  gem.authors     = ["Théo Berthier"]
  gem.email       = "berthiertheo@hotmail.fr"
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_runtime_dependency "fluentd", [">= 0.14.15", "< 2"]
  gem.add_runtime_dependency "google-cloud-pubsub", "~> 3.4.0"

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "test-unit"
  gem.add_development_dependency "test-unit-rr"
end
