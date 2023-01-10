#!/usr/bin/ruby

require 'optparse'
require 'ostruct'

LOG_LEVELS = %w[Critical Error Warning Notice Connect Info]

# Default values
options = OpenStruct.new
options.config = "/etc/tinyproxy/tinyproxy.conf"
options.config_filter = "/etc/tinyproxy/filter"
options.user = "nobody"
options.group = "nobody"
options.timeout = 600
options.port = 8888
options.loglevel = "Info"
options.allow = %w[127.0.0.1 ::1]


# Configuring options
OptionParser.new do |opts|
  opts.banner = "Usage: tinyproxycmd.rb [options]"
  
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

  opts.on('--loglevel LOG_LEVEL', LOG_LEVELS, 'Select log level (default: Info)'," (#{LOG_LEVELS})") do |level|
    options.level = level
  end

  opts.on('--allow IP1,IP2,HOST1,...', Array, 'Allow statements (default: \'127.0.0.1,::1)\'')  do |allow|
      options.allow = allow
  end

  opts.on('--filter FILTER1,FILTER2,...', Array, 'Filters (default: none')  do |filter|
      options.filter = filter
  end

  opts.on('--[no-]filter_default_deny', 'FilterDefaultDeny Yes')  do |filter_default_deny|
      options.filter_default_deny = filter_default_deny
  end

end.parse!

# Writing configuration file
File.open("#{options.config}", "w") do |config|
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

    if options.filter then
      config.write "Filter \"#{options.config_filter}\"\n"
      File.open("#{options.config_filter}", "w") do |config_filter|
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

