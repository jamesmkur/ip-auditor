# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ip_auditor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "ip_auditor"
  gem.version       = IpAuditor::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ["James Kurczodyna", "Kellen Hawley"]
  gem.email         = ["james@finedesigngroup.com"]
  gem.description   = "IP Auditor"
  gem.summary       = "Audits Apache vhosts and domain IPs"
  gem.homepage      = "https://github.com/jamesmkur/ip-auditor"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = ['audit_ips']
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.bindir        = 'bin'

  gem.add_dependency "net-ssh", "~> 2.6.7"
end
