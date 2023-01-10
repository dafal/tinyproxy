# Tinyproxy

This docker image is a super simple tinyproxy image based on alpine with a command wrapper to do without a tinyproxy.conf file.

## Usage

### Docker run

```
$ docker run dafal/tinyproxy --allow 192.168.0.0/16 --filter_default_deny --filter google\.com$,yahoo\.com$
```

This will create a container with a  tinyproxy configuration allowing access from 192.168.0.0/16 with default deny filter and exception to access *.google.com and *.yahoo.com.


### Compose

```
  proxy:
    image: dafal/tinyproxy
    command: --allow 192.168.0.0/16 --filter_default_deny --filter google\\.com$,yahoo\\.com$
    restart: unless-stopped
```

## Supported options

```
$ ruby tinyproxycmd.rb --help
Usage: tinyproxycmd.rb [options]
        --config CONFIG_FILE         Configuration file (default: /etc/tinyproxy/tinyproxy.conf)
        --config_filter FILTER_FILE  Configuration file (default: /etc/tinyproxy/filter)
        --user USER                  Define user or UID (default: nobody)
        --group GROUP                Define group  or GID (default: nobody)
        --timeout TIMEOUT            Define timeout in seconds (default: 600)
        --port PORT                  Define the port (default: 8888)
        --loglevel LOG_LEVEL         Select log level (default: Info)
                                      (["Critical", "Error", "Warning", "Notice", "Connect", "Info"])
        --allow IP1,IP2,HOST1,...    Allow statements (default: '127.0.0.1,::1)'
        --filter FILTER1,FILTER2,... Filters (default: none
        --[no-]filter_default_deny   FilterDefaultDeny Yes
$

```
