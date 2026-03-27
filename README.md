# Tinyproxy

This docker image is a super simple tinyproxy image based on Alpine Linux with a command wrapper to do without a tinyproxy.conf file.

## Usage

### Docker run

```
$ docker run dafal/tinyproxy --allow 192.168.0.0/16 --filter_default_deny --filter google\.com$,yahoo\.com$
```

This will create a container with a tinyproxy configuration allowing access from 192.168.0.0/16 with default deny filter and exception to access *.google.com and *.yahoo.com.

### Auto-allow local networks

Use `--allow-local-networks` to automatically detect all network interfaces attached to the container and allow their subnets — useful in Docker Compose projects where the subnet is not known in advance:

```
$ docker run dafal/tinyproxy --allow-local-networks --filter_default_deny --filter google\.com$,yahoo\.com$
```

### Compose

```yaml
  proxy:
    image: dafal/tinyproxy
    command: --allow 192.168.0.0/16 --filter_default_deny --filter google\\.com$,yahoo\\.com$
    restart: unless-stopped
```

With automatic network detection:

```yaml
  proxy:
    image: dafal/tinyproxy
    command: --allow-local-networks --filter_default_deny --filter google\\.com$,yahoo\\.com$
    restart: unless-stopped
```

### Compose outbound internet access control

This image is especially useful in Docker Compose projects where application
containers should not have direct outbound internet access.

The usual pattern is:

- connect the application container only to internal networks
- connect the Tinyproxy container to the internal network and a network with
  outbound access
- configure the application to use the proxy with `HTTP_PROXY` and
  `HTTPS_PROXY`

Example:

```yaml
services:
  app:
    image: my-app
    networks:
      - app_net
    environment:
      HTTP_PROXY: http://proxy:8888
      HTTPS_PROXY: http://proxy:8888
      NO_PROXY: proxy,localhost,127.0.0.1

  proxy:
    image: dafal/tinyproxy
    command:
      - --allow-local-networks
      - --filter_default_deny
      - --filter
      - github\.com$
      - --filter
      - rubygems\.org$
      - --filter
      - deb\.debian\.org$
    networks:
      - app_net
      - default
    restart: unless-stopped

networks:
  app_net:
    internal: true
```

In that setup, `app` cannot reach the internet directly because it is attached
only to the internal network. Internet-bound traffic must go through the
`proxy` service, and Tinyproxy then limits which domains can be reached.

### Managing allowed domains

For short lists, the original comma-separated form still works:

```yaml
command: --allow-local-networks --filter_default_deny --filter github\.com$,rubygems\.org$
```

For longer lists, `--filter` can now be repeated and remains easier to edit in
Compose files:

```yaml
command:
  - --allow-local-networks
  - --filter_default_deny
  - --filter
  - github\.com$
  - --filter
  - rubygems\.org$
  - --filter
  - pypi\.org$
```

Both styles can be mixed, and each filter is written as a separate line in the
generated Tinyproxy filter file.

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
        --filter FILTER1,FILTER2,... Filters, comma-separated or repeatable (default: none)
        --[no-]filter_default_deny   FilterDefaultDeny Yes
        --allow-local-networks       Automatically allow all local networks attached to the container
$

```
