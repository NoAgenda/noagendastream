# Liquidsoap runtime image for the No Agenda 24/7 stream

This directory builds the liquidsoap runtime image used by the No Agenda
stream containers. The image contains only the liquidsoap runtime; the
stream configuration (`noagenda.liq`, `include/`) is mounted into the
container at runtime from the deployment host and is not baked into the
image.

## Base

`docker.io/savonet/liquidsoap:v2.3.2` — the last liquidsoap release that ran
without issues in production. Upstream has moved on; do not bump the base
until the `next` branch has been validated on the test stream.

## Build

CI builds this image on every push (all branches and pull requests) and
publishes to GHCR only on `stable` and `next`:

```text
ghcr.io/noagenda/noagendastream:stable
ghcr.io/noagenda/noagendastream:next
```

Local builds (e.g. for a container runtime without registry access):

```sh
podman build -t localhost/lqs-savonet:v2.3.2-250407T1327Z containers/lqs-savonet/
```

The uid/gid sync in the Containerfile (liquidsoap → 1002:100) matches the
deployment host account (uid/gid 1002:100) so `UserNS=keep-id`
in the Quadlets maps cleanly.

Tag convention: `v<liquidsoap-version>-<build-timestamp UTC>`.
