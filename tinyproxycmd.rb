#!/usr/bin/ruby

require 'optparse'
require 'ostruct'
require 'socket'

LOG_LEVELS = %w[Critical Error Warning Notice Connect Info]

# Detect all local network subnets from non-loopback IPv4 interfaces.
def detect_local_network_subnets
  subnets = []
  Socket.getifaddrs.each do |ifaddr|
    next unless ifaddr.addr&.ipv4?
    next if ifaddr.addr.ip_address.start_with?('127.')
    next unless ifaddr.netmask

    ip = ifaddr.addr.ip_address
    netmask = ifaddr.netmask.ip_address
    prefix = netmask_to_prefix(netmask)
    next unless prefix

    network = calculate_network(ip, netmask)
    next unless network

    subnet = "#{network}/#{prefix}"
    subnets << subnet unless subnets.include?(subnet)
  end
  subnets
end

# Convert a dotted-decimal netmask to a CIDR prefix length.
def netmask_to_prefix(netmask)
  netmask.split('.').inject(0) do |sum, octet|
    sum + format('%08b', octet.to_i).count('1')
  end
end

# Calculate the network address for a given IP and dotted-decimal netmask.
def calculate_network(ip, netmask)
  ip_parts = ip.split('.').map(&:to_i)
  mask_parts = netmask.split('.').map(&:to_i)
  network_parts = ip_parts.zip(mask_parts).map { |i, m| i & m }
  network_parts.join('.')
end

# Default values
options = OpenStruct.new
options.config = '/etc/tinyproxy/tinyproxy.conf'
options.config_filter = '/etc/tinyproxy/filter'
options.user = 'nobody'
options.group = 'nobody'
options.timeout = 600
options.port = 8888
options.loglevel = 'Info'
options.allow = %w[127.0.0.1 ::1]
options.allow_local_networks = false

# Configuring options
OptionParser.new do |opts|
  opts.banner = 'Usage: tinyproxycmd.rb [options]'

  opts.on('--config CONFIG_FILE', 'Configuration file (default: /etc/tinyproxy/tinyproxy.conf)') do |config|
    options.config = config
  end

  opts.on('--config_filter FILTER_FILE', 'Configuration file (default: /etc/tinyproxy/filter)') do |config_filter|
    options.config_filter = config_filter
  end

  opts.on('--user USER', 'Define user or UID (default: nobody)') do |user|
    options.user = user
  end

  opts.on('--group GROUP', 'Define group  or GID (default: nobody)') do |group|
    options.group = group
  end

  opts.on('--timeout TIMEOUT', Integer, 'Define timeout in seconds (default: 600)') do |timeout|
    options.timeout = timeout
  end

  opts.on('--port PORT', Integer, 'Define the port (default: 8888)') do |port|
    options.port = port
  end

  opts.on('--loglevel LOG_LEVEL', LOG_LEVELS, 'Select log level (default: Info)', " (#{LOG_LEVELS})") do |level|
    options.level = level
  end

  opts.on('--allow IP1,IP2,HOST1,...', Array, 'Allow statements (default: \'127.0.0.1,::1)\'') do |allow|
    options.allow = allow
  end

  opts.on('--filter FILTER1,FILTER2,...', Array, 'Filters (default: none') do |filter|
    options.filter = filter
  end
  opts.on('--[no-]filter_default_deny', 'FilterDefaultDeny Yes') do |filter_default_deny|
    options.filter_default_deny = filter_default_deny
  end

  opts.on('--allow-local-networks', 'Automatically allow all local networks attached to the container') do
    options.allow_local_networks = true
  end
end.parse!

# Auto-detect all local interface subnets if requested
if options.allow_local_networks
  begin
    subnets = detect_local_network_subnets
    if subnets.empty?
      warn 'Warning: No local network subnets detected for --allow-local-networks'
    else
      subnets.each do |subnet|
        unless options.allow.include?(subnet)
          options.allow << subnet
          puts "Auto-allowed local network: #{subnet}"
        end
      end
    end
  rescue StandardError => e
    warn "Warning: Failed to detect local network subnets: #{e.message}"
  end
end

# Writing configuration file
File.open("#{options.config}", 'w') do |config|
  config.write "User #{options.user}\n"
  config.write "Group #{options.group}\n"
  config.write "Timeout #{options.timeout}\n"
  config.write "Port #{options.port}\n"
  config.write "LogLevel #{options.loglevel}\n"

  options.allow.each do |allow|
    config.write "Allow #{allow}\n"
  end

  if options.filter_default_deny
    config.write "FilterDefaultDeny Yes\n"
  else
    config.write "FilterDefaultDeny No\n"
  end

  if options.filter
    config.write "Filter \"#{options.config_filter}\"\n"
    File.open("#{options.config_filter}", 'w') do |config_filter|
      options.filter.each do |filter|
        config_filter.write "#{filter}\n"
      end
    end
  end
end

print "Starting tinyproxy with this configuration file:\n"
File.foreach(options.config).with_index do |line, line_no|
  puts "#{line_no + 1}: #{line}"
end

# Starting tinyproxy
system("tinyproxy -c #{options.config} -d")
