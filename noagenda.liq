# vim: ft=liq ts=4 sw=4 sts=4 et ai fdm=marker

# % -- noagenda.liq -- %

# Log dir
set("log.file.path","/stor/nastream/logs/noagenda.log")
set("init.concurrent",true)
set("request.metadata_decoders.override",true)

# Reset output if latency becomes >20s
set("root.max_latency",20.)

# Telnet settings
set("server.telnet", true)
set("server.telnet.bind_addr", "0.0.0.0")
set("server.telnet.port", 2300)

# Incoming stream's settings
set("harbor.bind_addr","0.0.0.0")

# Stream public info
streamname  = "No Agenda Stream"
streamdesc  = "All talk, no commercials. No Agenda."
streamgenre = "Talk radio"
streamurl   = "http://www.noagendashow.com/"

# The actual funky stuff happens
# via these included files
%include "include/secrets.liq"
%include "include/library.liq"
%include "include/radio.liq"

def pushit(h)
  output.icecast(%mp3.vbr(id3v2=true, internal_quality=4),
                 host         = h,
                 port         = 80,
                 password     = streampass,
                 name         = streamname,
                 description  = streamdesc,
                 genre        = streamgenre,
                 url          = streamurl,
                 mount        = streammount,
                 icy_metadata = "true",
                 stream)
end

pushit(nastream1)
pushit(nastream2)
pushit(nastream3)