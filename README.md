CAS Apache Reverse Proxy
========================

## Environment Variables

- `SERVER_NAME`: The hostname that Apache should answer to
- `CAS_HOST`: The hostname of the CAS server (e.g. cas.example.edu)
- `CAS_USERS`: A space delimited list of user IDs that should be authenticated
- `PROXY_TARGET`: The proxy target to protect

## Example
```yaml
version: '3.4'

services:
  proxy:
    image: wmit/cas_proxy
    ports:
      - target: 80
        published: 80
        protocol: tcp
        mode: ingress
    environment:
      SERVER_NAME: authed.example.edu
      CAS_HOST: cas.example.edu
      CAS_USERS: 'user1 user2'
      PROXY_TARGET: http://whoami:8000/

  whoami:
    image: jwilder/whoami
```
