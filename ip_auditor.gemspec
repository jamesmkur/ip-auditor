# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ip_auditor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["James"]
  gem.email         = ["james@finedesigngroup.com"]
  gem.description   = "IP Auditor"
  gem.summary       = "Audits Apache vhosts and domain IPs"
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ip_auditor"
  gem.require_paths = ["lib"]
  gem.version       = IpAuditor::VERSION

  gem.add_dependency "net-ssh", "~> 2.6.7"
end
