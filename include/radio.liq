# % -- include/radio.liq -- %
# vim: ft=liq ts=4 sw=4 sts=2 et ai fdm=marker

# Sound effects
elevator = playlist.safe(id="elevator", reload_mode="watch",
                    mode="normal",
                    "/stor/nastream/jingles/elevator.m3u")
elevator = audio_to_stereo(elevator)
elevator = rewrite_metadata([("title","$(title)"),
                             ("comment",streamurl)],elevator)

sweeper  = playlist.safe(id="sweeper", reload_mode="watch",
                    mode="normal",
                    "/stor/nastream/jingles/sweeper.m3u")
sweeper = audio_to_stereo(sweeper)
sweeper = rewrite_metadata([("title","$(title)"),
                             ("comment",streamurl)],sweeper)

# List of shows
nalist   = playlist(id="nalist", reload_mode="watch",
                    conservative=true,
                    mode="normal",
                    "/stor/nastream/mp3s/playlist.m3u")
nalist   = audio_to_stereo(nalist)
nalist   = rewrite_metadata([("title","$(title)"),
                             ("comment",streamurl)],nalist)

# Input harbor
adamlive   = input.harbor(id="adamlive", "/",
                        port=8000,
                        password=inpass,
                        icy=true)

# Input harbor
horolive = rewrite_metadata([("title", "LIVE: Dvorak and Horowitz Unplugged"),
                             ("comment",streamurl)],
                             audio_to_stereo(input.harbor(id="horolive", "/",
                             port=8002,
                             password=inpass,
                             icy=true)))

# Input harbor
alsolive   = input.harbor(id="alsolive", "/",
                        port=8004,
                        password=inpass,
                        icy=true)

# For some reason the last one in the list doesn't
# skip the currently playing podcast after disconnect
# so, let's add another one, but 'noop' it - not activate it.
nooplive   = input.harbor(id="nooplive", "/",
                        port=9000,
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
           [adamlive, alsolive, horolive, nooplive, once(playonce), f])
end

# The timed result
stream   = fallback(track_sensitive=false,
             [ switch(id="streamon", track_sensitive=false,
                 [({(4w or 7w) and 15h44m49s-17h59m49s},
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
