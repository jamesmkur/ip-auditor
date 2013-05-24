# require "ip_auditor/version"

module IpAuditor
  # grab domains from vhosts
  domain_text = `grep -r 'ServerName\\|ServerAlias' /etc/apache2/vhosts`
  # pull domains out of grep results
  domains = domain_text.scan(/(ServerName|ServerAlias)\s*?(.+)/i).to_a
  domains.each do |domain|
    # strip domains of whitespace
    d = domain[1].strip
    # perform an nslookup
    lookup = `nslookup #{d}`

    # strip output to IPs only
    output = lookup.scan(/(Non-authoritative answer:)(.*)/m).to_a
    ips = output[0][1].scan(/Address: (.*)/).to_a if output[0]

    # output results
    puts d
    if ips
      puts ips
    else
      puts 'NO IP FOUND'
    end
    puts '====='
  end
end
