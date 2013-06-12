# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-learning"
  s.version     = "0.0.1" 
  s.authors     = ["matthias alker"]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = %q{itelligence Siri Proxy for learning content}
  s.description = %q{ This is a Siri Proxy Plugin for internal use by the itelligence AG which corresponds with learning content with a SAP Netweaver GW Backend }

  s.rubyforge_project = "siriproxy-learning"

  s.files         = `git ls-files 2> /dev/null`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/* 2> /dev/null`.split("\n")
  s.executables   = `git ls-files -- bin/* 2> /dev/null`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "cora"
  s.add_runtime_dependency "httparty"
  s.add_dependency "ruby_odata"
end
