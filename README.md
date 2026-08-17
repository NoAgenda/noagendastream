This is the Liquidsoap code as used by the No Agenda stream, home of the No
Agenda Podcast, by Adam Curry and John C. Dvorak.

Listen live twice a week:

http://www.noagendashow.com/
http://www.noagendastream.com/

Outside live hours we stream repeats of podcasts we like.

This is community supported work. Let us know you appreciate the effort.

Donations: http://dvorak.org/na

All talk. No Commercials. No Agenda.

## Runtime and branches

The stream configuration runs on Liquidsoap 2.4.5. The runtime image is built
from [`containers/lqs-savonet/`](containers/lqs-savonet/); the configuration
and secrets are mounted at runtime and are not baked into the image.

- `stable` contains the production configuration.
- `next` contains changes being validated on the test stream before promotion
  to production.

## Metadata

Automatic track metadata is normalized with `metadata.map`, which adds the
public stream URL while preserving the title and other metadata fields.
Listener-facing now-playing metadata can also be overridden manually through
the custom Liquidsoap server command:

```text
metadata.update song==<now playing text>
```

That command uses `icy.update_metadata` for the main Icecast output. A later
track metadata event replaces the manual override in the normal way.

Host-specific helper scripts and `include/secrets.liq` are intentionally not
stored in this repository.
