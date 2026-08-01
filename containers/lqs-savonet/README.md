# Liquidsoap runtime image for the No Agenda 24/7 stream

This directory builds the liquidsoap runtime image used by the No Agenda
stream containers. The image contains only the liquidsoap runtime; the
stream configuration (`noagenda.liq`, `include/`) is mounted into the
container at runtime from the deployment host and is not baked into the
image.

## Base

`docker.io/savonet/liquidsoap:v2.4.5` — validated with the `next` branch on
the test stream, including playlist playback, Icecast outputs, metadata,
harbor input, live-source transitions, and an extended runtime test.

## Build

CI builds this image on every push to `stable` and `next` and publishes to
GHCR:

```text
ghcr.io/noagenda/noagendastream:stable
ghcr.io/noagenda/noagendastream:next
```

Local builds (e.g. for a container runtime without registry access):

```sh
podman build -t localhost/lqs-savonet:v2.4.5-260801T0932Z containers/lqs-savonet/
```

The uid/gid sync in the Containerfile (liquidsoap → 1002:100) matches the
deployment host account (uid/gid 1002:100) so `UserNS=keep-id`
in the Quadlets maps cleanly.

Tag convention: `v<liquidsoap-version>-<build-timestamp UTC>`.
