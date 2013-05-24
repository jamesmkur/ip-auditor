# require "ip_auditor/version"
require 'net/ssh'

module IpAuditor
  # puts ARGV[0]
  server = ARGV[0] || ''
  user = ARGV[1] || ''
  pass = ARGV[2] || ''

  Net::SSH.start(server, user, password: pass) do |ssh|

    # grab domains from vhosts
    domain_text = ssh.exec!("grep -r '<VirtualHost\\|DocumentRoot\\|ServerName\\|ServerAlias' /etc/apache2/sites-enabled")
    # domain_text = `grep -r '<VirtualHost\\|DocumentRoot\\|ServerName\\|ServerAlias' /etc/apache2/vhosts`
    
    domain_text.each_line do |line|
      puts "\n============\n"+line+"============" if line['<VirtualHost']
      puts line.scan(/DocumentRoot(.*)/).to_a[0][0].strip if line['DocumentRoot']
      domain_line = line.scan(/(ServerName|ServerAlias)(.*)/).to_a
      if domain_line[0]
        domains = domain_line[0][1].strip.split(' ')
        domains.each do |domain|
          puts domain if domain
          # perform an nslookup
          lookup = `nslookup #{domain}`

          # strip output to IPs only
          output = lookup.scan(/(Non-authoritative answer:)(.*)/m).to_a
          ips = output[0][1].scan(/Address: (.*)/).to_a if output[0]

          # output results
          if ips
            puts ips
          else
            puts 'DOMAIN LOOKUP FAILED'
          end
        end
      end
    end

    # pull domains out of grep results
    # domains = domain_text.scan(/(ServerName|ServerAlias)\s*?(.+)/i).to_a
    # domains.each do |domain|
    #   # strip domains of whitespace
    #   d = domain[1].strip
    #   # perform an nslookup
    #   lookup = `nslookup #{d}`

    #   # strip output to IPs only
    #   output = lookup.scan(/(Non-authoritative answer:)(.*)/m).to_a
    #   ips = output[0][1].scan(/Address: (.*)/).to_a if output[0]

    #   # output results
    #   puts d
    #   if ips
    #     puts ips
    #   else
    #     puts 'NO IP FOUND'
    #   end
    #   puts '====='
    # end

  end

end
