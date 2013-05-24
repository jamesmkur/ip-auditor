# IP Auditor

The IP Auditor looks through your Apache vhosts to compile a list of apps on the server, what domains are being listened for and what IP the domain is actually pointing to.

This allows you to quickly track which domains are active and which domains are point elsewhere.

## Installation

* clone this repo
* cd into the repo
* run `bundle install`

## Usage

To use the Auditor, cd into the cloned repo and run the following command:

	ruby ./lib/ip_auditor.rb [server name/IP] [user] [password]

Example:

	ruby ./lib/ip_auditor.rb someserver.com myuser secret

## Output

The Auditor will return a crude report for each VirtualHost in the following format.

	============
	/path/to/vhost/vhostname: <VirtualHost  [IP]:[port]>
	============
	[domain-1]
	[IP domain-1 is actually pointing to]
	[domain-2]
	[IP domain-2 is actually pointing to]
	[/path/to/app/DocumentRoot]

## TODO

* release as a Gem (currently you have to clone repo and run ruby script)
* prompt user for password instead vs entering it with main command