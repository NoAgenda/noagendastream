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
def_buffer = 10. # seconds to buffer

adamlive   = input.harbor(id="adamlive", "/",
                        port=adam_inport,
                        password=adampass,
                        buffer=def_buffer,
                        icy=true)

darrenlive = input.harbor(id="darrenlive", "/",
                        port=darren_inport,
                        password=darrenpass,
                        buffer=def_buffer,
                        icy=true)

# Input harbor
horolive = rewrite_metadata([("title", "LIVE: Dvorak and Horowitz Unplugged"),
                             ("comment",streamurl)],
                             input.harbor(id="horolive", "/",
                             port=horo_inport,
                             password=inpass,
                             buffer=def_buffer,
                             icy=true))

# Input harbor
alsolive   = input.harbor(id="alsolive", "/",
                        port=also_inport,
                        password=inpass,
                        buffer=def_buffer,
                        icy=true)

onair    = mksafe(rotate(id="onair",  [elevator,sweeper]))
offair   = mksafe(rotate(id="offair", [nalist,sweeper]))

# Helper to check if a source is one of the active live inputs
def is_live_input(s) =
  let sid = source.id(s)
  sid == source.id(adamlive) or
  sid == source.id(darrenlive) or
  sid == source.id(horolive) or
  sid == source.id(alsolive)
end

# The transition function that determines HOW we switch
def custom_transition(a, b) =
  log(level=3, "Transition: '#{source.id(a)}' -> '#{source.id(b)}' (live input? #{is_live_input(a)})")

  # CONDITION: Are we switching away from a LIVE input?
  if is_live_input(a) then
    log(level=3, "Transition action: live ended; skip nalist track, play sweeper, then resume offair (target id '#{source.id(b)}').")

    # 1. Skip the current/interrupted track in nalist
    #    This ensures 'offair' will grab the NEXT one.
    source.skip(nalist)

    # 2. Return a sequence: FIRST the sweeper, THEN the offair source (which will start the next nalist track)
    sequence([sweeper, b])
  # ELSE: For all other transitions (e.g., within nalist, from playlist to live)
  else
    log(level=3, "Transition action: standard switch to '#{source.id(b)}'.")
    # Simply return the new source 'b' for an abrupt transition.
    b
  end
end

def playout(fallback_source) =
  # The live sources, plus 'once(sweeper)' as a temporary filler
  # if there is NO live source at startup.
  # The 'fallback_source' is typically 'onair' or 'offair'.
  fallback(id="main_fallback", # Give the fallback an ID for logging/debugging
           track_sensitive=false,
           transitions=[custom_transition, custom_transition, custom_transition,
                        custom_transition, custom_transition, custom_transition],
           [adamlive, darrenlive, horolive, alsolive, once(sweeper), fallback_source])
end

# The timed result (stream definition) now uses the new playout structure
stream   = fallback(track_sensitive=false,
             [ switch(id="streamon", track_sensitive=false,
                 # During live hours, use 'onair' as the fallback within playout
                 ## Summer hours #fuckDST
                 [({(4w or 7w) and 13h59m30s-19h59m49s}, playout(onair))]),
                 ## Winter hours #fuckDST
#                 [({(4w or 7w) and 14h59m30s-20h59m49s}, playout(onair))]),

               # Outside live hours, use 'offair' as the fallback within playout
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

# Function to show the currently playing content
def show_current(source_name)
  # Select the source based on the input parameter
  current_source = if source_name == "music" then musicstream else stream end

  # Get the last metadata from the source
  meta = current_source.last_metadata()

  # Use null.case to handle the presence or absence of metadata
  result = null.case(meta,
    # If there's no metadata (nothing)
    fun () -> "No metadata available - likely a live stream is currently playing",
    # If there is metadata (something)
    fun (m) -> "Currently playing: " ^ m["title"] ##^ " (Comment: " ^ m["comment"] ^ ")"
  )

  # Return the result
  result
end

# Register the command with the telnet server
server.register("current",
                description="Show what is currently playing (usage: current [stream|music])",
                usage="current [stream|music]",
                show_current)
