# % -- include/radio.liq -- %
# vim: ft=liq ts=4 sw=4 sts=4 et ai fdm=marker

livein = input.harbor(id="livein", "/",port=9200,
                           password=streampass,
                           icy=true)
livein = audio_process(livein)

# Elevator music
elevator = playlist(id="elevator", "/stor/nastream/jingles/elevator.m3u")
sweeper  = playlist(id="sweeper","/stor/nastream/jingles/sweeper.m3u")
swelev   = playlist(id="swelev", "/stor/nastream/jingles/swelev.m3u")

# Shows, uploaded by Adam
# with reload_mode="seconds" and reload="300", reload every 300 seconds
# It can also watch, if reload_mode="watch"
# It plays the files in order specified due to mode="normal"
# By default it will queue 10.0 seconds of audio (varname is 'length')
# And with 'conservative' set to true, estimated remaining time on the current
# track is not considered when computing queue length.
nalist  = playlist(id="nalist", reload_mode="watch",
                   conservative=true,
                   mode="normal",
                   "/stor/nastream/mp3s/playlist.m3u")
nalist  = audio_to_stereo(nalist)
nalist  = rewrite_metadata([("title","$(title)"),
                               ("comment","http://noagendastream.com/")],nalist)
nalist  = audio_process(nalist)
nalist  = mksafe(rotate([sweeper, nalist]))

onair   = rotate([swelev, sweeper, elevator])
onair   = mksafe(fallback.skip(input=livein, onair))
onair   = fallback(track_sensitive=false,[livein, onair])

offair  = fallback.skip(input=livein, nalist)

stream  = fallback(track_sensitive=false, [
                       switch(track_sensitive=false,
                              [ ({(4w or 7w) and 16h44m49s-20h14m49s}, onair)]),
                       switch(track_sensitive=false,
                              [ ( {true}, offair ) ] ),
                       offair])

# Register the seek function to the telnet server
server.register(namespace=source.id(nalist),
                description="Seek to a relative position \
                             in source #{source.id(nalist)}",
                usage="seek <duration>",
                "seek",seek(nalist))
