# md3-devenv-aws

```
#!/bin/bash
wget -O- https://raw.githubusercontent.com/swrightmdedge/md3-devenv-aws/master/ubuntu-init.sh|\
 PASSWORD="<changeme>"\
 TOKEN="<duck-dns-token>"\
 HOST="<duckdnshost>"\
 EMAIL="<your@email>"\
 bash
```

PASSWORD = anything
TOKEN = DuckDNS Token for Subdomain
HOST = DuckDNS Subdomain (ex. md3-dev-steve.duckdns.org)
EMAIL = Email used for encryption certificate

