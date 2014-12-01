# % -- include/radio.liq -- %
# vim: ft=liq ts=4 sw=4 sts=2 et ai fdm=marker

# Sound effects
elevator = playlist.safe(id="elevator", "/stor/nastream/jingles/elevator.m3u")
sweeper  = playlist.safe(id="sweeper","/stor/nastream/jingles/sweeper.m3u")

# List of shows
nalist   = playlist(id="nalist", reload_mode="watch",
                    conservative=true,
                    mode="normal",
                    "/stor/nastream/mp3s/playlist.m3u")
nalist   = audio_to_stereo(nalist)
nalist   = rewrite_metadata([("title","$(title)"),
                             ("comment",streamurl)],nalist)

# Input harbor
livein   = input.harbor(id="livein", "/",
                        port=9200,
                        password=inpass,
                        icy=true)

onair    = mksafe(rotate(id="onair",  [elevator,sweeper]))
offair   = mksafe(rotate(id="offair", [nalist,sweeper]))

# Playout routine
def playout(f, ~jig=false, ~skip_target=nalist, ~playonce=sweeper)
  def trans(a, b)
    source.skip(a)
    if jig then
      source.skip(skip_target)
    end
    sequence([a,b])
  end
  fallback(track_sensitive=false,transitions=[trans,trans],
           [livein, once(playonce), f])
end

# The timed result
stream   = fallback(track_sensitive=false,
             [ switch(id="streamon", track_sensitive=false,
                 [({(4w or 7w) and 16h44m49s-20h14m49s},
                   playout(onair, jig=true))]),
               playout(offair)])

# ..which we want to process
stream   = audio_process(stream)

# Register the seek function to the telnet server
server.register(namespace=source.id(nalist),
                description="Seek to a relative position \
                             in source #{source.id(nalist)}",
                usage="seek <duration>",
                "seek",seek(nalist))
