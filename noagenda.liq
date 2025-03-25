# vim: ft=liq ts=4 sw=4 sts=2 et ai fdm=marker

# % -- noagenda.liq -- %

# Read secrets including the basepath variable
%include "include/secrets.liq"

# Log dir
settings.log.file.path := basepath ^ "/logs/noagenda.log"
settings.charset.encodings := ["UTF-8", "ISO-8859-1", "UTF-16"]

# Telnet settings
settings.server.telnet := true
settings.server.telnet.bind_addr := "0.0.0.0"
settings.server.telnet.port := 2300

# Incoming stream's settings
settings.harbor.bind_addrs := ["0.0.0.0"]


# Stream public info
streamname  = "No Agenda Stream"
streamdesc  = "All talk, no commercials. No Agenda."
streamgenre = "Talk radio"
streamurl   = "http://www.noagendastream.com/"
musicname  = "No Agenda Stream v4v Music"
musicdesc  = "All v4v music, no commercials. No Agenda."


# The actual funky stuff happens via these included files
%include "include/library.liq"
%include "include/radio.liq"

def pushit(i, h, n, d, m, s)
  output.icecast(%mp3.vbr(id3v2=true, internal_quality=4),
                 id                = i,
                 host              = h,
                 port              = streamport,
                 encoding          = "UTF-8",
                 password          = streampass,
                 name              = n,
                 description       = d,
                 genre             = streamgenre,
                 url               = streamurl,
                 mount             = m,
                 send_icy_metadata = true,
                 s)
end

clock.assign_new(id="naclock",[
  pushit(nastream1_name,  nastream1_host,  streamname,  streamdesc,  streammount,  stream),
  pushit(nastream2_name,  nastream2_host,  streamname,  streamdesc,  streammount,  stream),
  pushit(nastream3_name,  nastream3_host,  streamname,  streamdesc,  streammount,  stream),
  pushit(nastream4_name,  nastream4_host,  streamname,  streamdesc,  streammount,  stream),

  pushit(nastream1_name,  nastream1_host,  musicname,   musicdesc,   musicmount,   musicstream),
  pushit(nastream2_name,  nastream2_host,  musicname,   musicdesc,   musicmount,   musicstream),
  pushit(nastream3_name,  nastream3_host,  musicname,   musicdesc,   musicmount,   musicstream),
  pushit(nastream4_name,  nastream4_host,  musicname,   musicdesc,   musicmount,   musicstream),

])
