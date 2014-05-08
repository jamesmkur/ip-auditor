# IP Auditor

The IP Auditor looks through your Apache vhosts to compile a list of apps on the server, what domains are being listened for and what IP each domain is actually pointing to.

This allows you to quickly track which domains and apps are active and which are pointing elsewhere.

## Installation

* clone this repo
* cd into the repo
* run `bundle install`

## Usage

To use the Auditor, cd into the cloned repo and run the following command:

	ruby ./lib/ip_auditor.rb [server name/IP] [user] [options]

Example:

	ruby ./lib/ip_auditor.rb someserver.com myuser

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

## Options

* -p [PORT NUMBER] : Specify a port number (default is 22)
* -c [FILE NAME (optional)]: Output to .csv file instead of terminal (can specify a name)
* -v : Output more information as to what's happening
* -e [prod|stage|dev|etc.]: Specify an environment to output (defaults to 'all'; determined by passenger config files)

## TODO

* release as a Gem (currently you have to clone repo and run ruby script)

## License

Copyright (c) 2013 James Kurczodyna

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.