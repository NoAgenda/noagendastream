# % -- include/radio.liq -- %
# vim: ft=liq ts=4 sw=4 sts=2 et ai fdm=marker

# Sound effects
elevator = mksafe(playlist(id="elevator", reload_mode="watch",
                    mode="normal",
                    basepath ^ "/jingles/elevator.m3u"))
elevator = rewrite_metadata([("title","$(title)"),
                             ("comment",streamurl)],elevator)

sweeper = mksafe(playlist(id="sweeper", reload_mode="watch",
                    mode="normal",
                    basepath ^ "/jingles/sweeper.m3u"))
sweeper = rewrite_metadata([("title","$(title)"),
                             ("comment",streamurl)],sweeper)

# List of shows
nalist   = playlist(id="nalist", reload_mode="watch",
                    mode="normal",
                    prefetch=3,
                    basepath ^ "/mp3s/playlist.m3u")
nalist   = rewrite_metadata([("title","$(title)"),
                             ("comment",streamurl)],nalist)

musiclist = playlist(id="musiclist", reload_mode="watch",
                    mode="normal",
                    prefetch=3,
                    basepath ^ "/mp3s/playlist-v4vmusic.m3u")
musiclist = rewrite_metadata([("title","$(title)"),
                             ("comment",streamurl)],musiclist)

# Input harbor
adamlive   = input.harbor(id="adamlive", "/",
                        port=adam_inport,
                        password=inpass,
                        icy=true)

# Input harbor
horolive = rewrite_metadata([("title", "LIVE: Dvorak and Horowitz Unplugged"),
                             ("comment",streamurl)],
                             input.harbor(id="horolive", "/",
                             port=horo_inport,
                             password=inpass,
                             icy=true))

# Input harbor
alsolive   = input.harbor(id="alsolive", "/",
                        port=also_inport,
                        password=inpass,
                        icy=true)
#alsolive = rewrite_metadata([("title", "No Agenda Stream LIVE!"), ("comment", streamurl)], alsolive)

# For some reason the last one in the list doesn't
# skip the currently playing podcast after disconnect
# so, let's add another one, but 'noop' it - not activate it.
nooplive   = input.harbor(id="nooplive", "/",
                        port=noop_inport,
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
#	 playout(offair))
             [ switch(id="streamon", track_sensitive=false,
                 [({(4w or 7w) and 17h59m30s-17h59m49s},
                   playout(onair, jig=true))]),
               playout(offair)])

# ..which we want to process
stream   = audio_process(stream)

musicstream = audio_process(mksafe(rotate(id="music", [musiclist,sweeper])))

# Register the seek function to the telnet server
server.register(namespace=source.id(nalist),
                description="Seek to a relative position \
                             in source #{source.id(nalist)}",
                usage="seek <duration>",
                "seek", fun(t) -> seek(nalist, t))
