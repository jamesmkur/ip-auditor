# require "ip_auditor/version"
require "uri"

module IpAuditor
  domain_text = `grep -r 'ServerName' /etc/apache2/vhosts`
  domains = domain_text.scan(/(ServerName|ServerAlias)\s*?(.+)/i).to_a
  domains.each do |domain|
    d = domain[1].strip
    output = `nslookup #{d}`
    puts output
  end
end
