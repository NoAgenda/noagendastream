# % -- include/radio.liq -- %
# vim: ft=liq ts=4 sw=4 sts=4 et ai fdm=marker

# Elevator music
elevator = single(id="elevator", "/stor/nastream/jingles/elevator.mp3")
sweeper  = single(id="sweeper","/stor/nastream/jingles/sweeper.mp3")
#sweeper  = single(id="sweeper", "/stor/nastream/jingles/jcdpockets.mp3")

# Shows, uploaded by Adam
nalist   = playlist(id="nalist", reload_mode="watch",
                    conservative=true,
                    mode="normal",
                    "/stor/nastream/mp3s/playlist.m3u")
nalist   = audio_to_stereo(nalist)
nalist   = rewrite_metadata([("title","$(title)"),
                             ("comment","http://noagendastream.com/")],nalist)

# Input harbour
livein   = input.harbor(id="livein", "/",
                        port=9200,
                        password=streampass,
                        icy=true)

onair    = mksafe(rotate(id="onair",  [elevator,sweeper]))
offair   = mksafe(rotate(id="offair", [nalist,sweeper]))

def goplay(f, ~jiggle=false, ~skip_target=nalist, ~playonce=sweeper)
  def trans(a, b)
    source.skip(a)
    if jiggle then
      source.skip(skip_target)
    end
    sequence([a,b])
  end
  fallback(track_sensitive=false,transitions=[trans,trans],[livein, once(playonce), f])
end
stream   = fallback(track_sensitive=false,
             [ switch(id="streamon", track_sensitive=false,
               [ ({(4w or 7w) and 16h44m49s-20h14m49s}, goplay(onair, jiggle=true)),
                 ({(1w or 2w) and 01h58m-01h59m}, goplay(onair, jiggle=true)) ]),
               goplay(offair)])
stream   = audio_process(stream)

# Register the seek function to the telnet server
server.register(namespace=source.id(nalist),
                description="Seek to a relative position \
                             in source #{source.id(nalist)}",
                usage="seek <duration>",
                "seek",seek(nalist))
