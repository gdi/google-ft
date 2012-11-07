# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "google-ft"
  s.version     = "0.0.2"
  s.authors     = ["Jon Durbin"]
  s.email       = ["jond@greenviewdata.com"]
  s.homepage    = "https://github.com/gdi/google-ft"
  s.summary     = %q{Work with Google Fusion Tables using a service account}
  s.description = %q{Work with Google Fusion Tables using a service account}

  s.rubyforge_project = "google-ft"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rspec'
  s.add_dependency 'bundler'
  s.add_dependency 'google-sa-auth'
  s.add_dependency 'json'
end
