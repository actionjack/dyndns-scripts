#!/usr/bin/env ruby
require 'rubygems'
require 'net/https'
require 'uri'
require 'json'
require 'openssl'
require 'yaml'


# Set your IP address and Failover IP address on the command line
IPADDR = ARGV[0]
FAILOVER_IPADDR = ARGV[1]


# Set the desired parameters
CONFIG = YAML.load_file(ENV['HOME']+"/.config.yaml") unless defined? CONFIG

CUSTOMER_NAME = CONFIG['customer_name']
USER_NAME = CONFIG['user_name']
PASSWORD = CONFIG['password']
ZONE = CONFIG['zone']
FQDN = CONFIG['fqdn']

# Set up our HTTP object with the required host and path
url = URI.parse('https://api2.dynect.net/REST/Session/')
headers = {"Content-Type" => 'application/json'}
http = Net::HTTP.new(url.host, url.port)
#http.set_debug_output $stderr
http.use_ssl = true

# Login and get an authentication token that will be used for all subsequent requests.
session_data = {:customer_name => CUSTOMER_NAME, :user_name => USER_NAME, :password => PASSWORD}

resp = http.post(url.path, session_data.to_json, headers)
result = JSON.parse(resp.body)

auth_token = ''
if result['status'] == 'success'
  auth_token = result['data']['token']
else
  puts "Command Failed:\n"
  # the messages returned from a failed command are a list
  result['msgs'][0].each { |key, value| print key, " : ", value, "\n" }
end

# New headers to use from here on with the auth-token set
headers = {"Content-Type" => 'application/json', 'Auth-Token' => auth_token}

# Stage failover changes
data = {"failover_data" => FAILOVER_IPADDR, "address" => IPADDR, "failover_mode" => "ip", "auto_recover" => "N"}
input = data.to_json

#  Put the failover changes into the system
url = URI.parse("https://api2.dynect.net/REST/Failover/#{ZONE}/#{FQDN}")
resp = http.put(url.path, input, headers)

print 'Put Failover Response: ', resp.body, '\n'

# Logout
url = URI.parse('https://api2.dynect.net/REST/Session/')
resp = http.delete(url.path, headers)
print 'DELETE Session Response: ', resp.body, '\n'
