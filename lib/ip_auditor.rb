# require "ip_auditor/version"
require 'net/ssh'
require 'optparse'
require 'ostruct'
require 'yaml'

begin
  require 'io/console'
rescue LoadError
end


module IpAuditor

  def IpAuditor.set_options
    @options = OpenStruct.new

    @options.verbose = false
    @options.environment = 'all'

    # parse the options passed in through the terminal
    OptionParser.new do |opts|
      opts.banner = 'Usage: ip.auditor.rb [server name/IP] [username] [options]'

      # get the port number
      opts.on('-p', '--port [PORT NUMBER]', 'Port (default is 22)') do |p|
        @options.port = p
      end

      # check whether to output data as csv, possibly get the name
      opts.on('-c', '--csv [FILENAME]', 'Output data as CSV file') do |c|
        @options.csv = true
        @options.csv_name = c =~ /[^[:space:]]/ ? c : nil
      end

      # check whether output more information
      opts.on('-v', '--verbose', 'Print out more information about what\'s happening') do |v|
        @options.verbose = true
      end

      # specify the environment we're checking
      opts.on('-e', '--environment [prod|stage|dev|etc.]', 'Print only the sites that have environment specified in their passenger files (default is all)') do |e|
        @options.environment = e
      end

    end.parse!

    # prompt for password
    @options.pass = IpAuditor.get_password
    puts "\n"

    # set the connection variables
    @options.server = ARGV[0] || ''
    @options.user = ARGV[1] || ''
    @options.port = @options.port || 22
    @options.pass = @options.pass || ''
    @options.csv_name = @options.csv_name || @options.server

  end

  # prompt for and return password
  def IpAuditor.get_password
    if STDIN.respond_to?(:noecho)
    puts "Password: "
    STDIN.noecho(&:gets).chomp
  else
    `read -s -p "Password: " password; echo $password`.chomp
  end
  end

  # get and parse the yaml passenger config file if available, else return false
  def IpAuditor.get_passenger_file(ssh,file_name)

    puts "Getting passenger information for #{file_name}..." if @options.verbose

    yaml_file = ssh.exec!("find /etc/passenger.d -name '#{file_name}.yml' -exec cat {} \\;")

    # if blank, return false
    if yaml_file !~ /[^[:space:]]/
      return false
    else
      begin
        content = YAML.load(yaml_file)
      rescue ArgumentError
        return false
      end
    end

  end

  # get the rails version for the site, else return nil
  def IpAuditor.get_rails_version(ssh,gemset)

    puts "Getting the rails version..." if @options.verbose
    rails_version = ssh.exec!("/usr/local/rvm/bin/rvm #{gemset} do gem list")[/\nrails \((.*?)\)\n/,1]

  end


  # get the rails information using passenger, or return false
  def IpAuditor.get_rails_information(ssh,file_name)

    rails_info = get_passenger_file(ssh,file_name)

    if rails_info
      rails_info['rails_version'] = get_rails_version(ssh,rails_info['rvm'])
      return rails_info
    else
      return false
    end

  end

  def IpAuditor.check_site_status(domain)
    lookup = `nslookup #{domain}`

    # strip output to IPs only
    output = lookup[/Non-authoritative answer:(.*)/m,1]
    ip = !output.nil? ? output[/Address: (.*)/m,1] : false

    # output IP address or message saying lookup failed
    if ip
      return ip
    else
      return 'DOMAIN LOOKUP FAILED'
    end
  end

  def IpAuditor.get_site_information(ssh)
    data = []
    current_file_path = '--'
    current_file = nil
    directory = ''
    virtualhost = ''
    domain_statuses = []

    # get all relevant lines from vhost files
    domain_text = ssh.exec!("grep -r '<VirtualHost\\|DocumentRoot\\|<Directory\\|ServerName\\|ServerAlias' /etc/apache2/sites-enabled")

    # parse each line for relevant data
    domain_text.each_line do |line|

      # if we're still looking at the same file, get information
      if line[current_file_path]
        virtual_host = line[/<VirtualHost/] ? line[/<VirtualHost (.*)>/,1].strip.split(" ").join(", ") : virtual_host
        directory = line[/DocumentRoot/] ? line[/DocumentRoot\s*?(.*)/,1] : directory

        domain = line[/(ServerName|ServerAlias)(.*)/] ? line[/(ServerName|ServerAlias)(.*)/,2].strip : nil

        if !(domain.nil?)
          domain_statuses << [domain,IpAuditor.check_site_status(domain)]
        end

      else
        # if this is a new file, get rails info and push into data array before resetting variables
        if !(current_file.nil?)
          rails_info = IpAuditor.get_rails_information(ssh,current_file)

          if rails_info && (rails_info['environment'][@options.environment] || @options.environment == 'all')
            data << [current_file, rails_info['environment'], rails_info['cwd'], rails_info['rvm'], rails_info['rails_version'], virtual_host,domain_statuses].flatten
          elsif @options.environment == 'all'
            data << [current_file,'',directory,'','',virtual_host,domain_statuses].flatten
          end
        end

        # reset the per-file variables
        current_file_path = line[/(.*?):/,1]
        current_file = current_file_path[/.*\/(.*?\.com$)/,1]
        virtual_host = line[/<VirtualHost/] ? line[/<VirtualHost (.*)>/,1].strip.split(" ").join(", ") : ''
        directory = ''
        domain_statuses = []

      end
    end

    data

  end


  def IpAuditor.write_to_csv(headers,csv_data)
    require 'csv'
    CSV.open("IP Audit - #{@options.csv_name}.csv", "w") do |csv|
      csv << headers
      csv_data.each do |line|
        csv << line
      end
    end
  end




  # set the options for this instance
  IpAuditor.set_options

  puts "Opening SSH connection to #{@options.server}..." if @options.verbose

  begin

    # open an ssh connection
    Net::SSH.start(@options.server, @options.user, {port: @options.port, password: @options.pass}) do |ssh|

      puts "Connection opened! Finding apache site files..." if @options.verbose

      # find lines of interest in vhosts, assumes location is /etc/apache2/sites-enabled
      domain_text = ssh.exec!("grep -r '<VirtualHost\\|DocumentRoot\\|<Directory\\|ServerName\\|ServerAlias' /etc/apache2/sites-enabled")


      # output to .csv file
      if !@options.csv.nil? && @options.csv


        puts "Parsing the vhosts files ..." if @options.verbose

        csv_headers = ['Site','Environment','Directory','Gemset','Rails Version','Virtual Host','Site Statuses']
        csv_data = IpAuditor.get_site_information(ssh)

        puts "Writing to .csv file..." if @options.verbose
        IpAuditor.write_to_csv(csv_headers,csv_data)

        puts "File saved to ./IP Audit - #{@options.csv_name}.csv!"



      # output to terminal
      else

        data_headers = ['Site','Environment','Directory','Gemset','Rails Version','Virtual Host','Site Statuses']
        site_data = IpAuditor.get_site_information(ssh)

        last_header_index = data_headers.length - 1

        site_data.each do |site|

          puts "\n============\n#{site[0]}\n============"


          (1...site.length).each do |index|
            if site[index] =~ /[^[:space:]]/

              if !data_headers[index].nil? && index < last_header_index
                puts "#{data_headers[index]}: #{site[index]}"

              elsif index == last_header_index
                puts "------------\n#{data_headers[index]}------------"
                puts site[index]
              else
                puts site[index]
              end

            end

          end

        end

      end

    end

    # catch the basic errors
  rescue SocketError => e
    puts "Socket Error! Is your domain name correct?"
  rescue Net::SSH::AuthenticationFailed
    puts "Authentication Error! Did you correctly type in your username and password?"
  # rescue Exception => e
  #   puts "Error! Have you specified the correct port, perhaps?"
  end

end
