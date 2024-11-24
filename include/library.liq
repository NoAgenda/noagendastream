# % -- include/library.liq -- %
# vim: ft=liq ts=4 sw=4 sts=2 et ai fdm=marker

####################################
# The server seeking function
# Seeks to a position in the stream
def seek(s, t) =
  t = float_of_string(default=0., t)
  log("Seeking #{t} sec")
  ret = source.seek(s, t)
  "Seeked #{ret} seconds."
end

#####################
def audio_process(s)
  gain = ref(3.)
  ratio = ref(3.)
  threshold = ref(-15.)
  target = ref(-13.)

  s = normalize(target=target(), s)
  s = compress(gain=gain(), ratio=ratio(), threshold=threshold(), s)
  s.{processing_parameters={gain=gain, ratio=ratio, threshold=threshold, target=target}}
end
########################################
# Manually update icecast metadata via telnet
def icy_update(v) =
  # Parse the argument
  l = string.split(separator=",,", v)
  def split(l, v) =
    v = string.split(separator="==", v)
    if list.length(v) >= 2 then
      list.append(l, [(list.nth(v, 0, default=""), list.nth(v, 1, default=""))])
    else
      l
    end
  end
  meta = list.fold(split, [], l)

  def upd(h)
    icy.update_metadata(mount=streammount,
                        password=streampass,
                        host=h,
                        protocol="http",
                        port=streamport,
                        meta)
  end

  # Update metadata
  upd(nastream1_host)
  upd(nastream2_host)
  upd(nastream3_host)
  upd(nastream4_host)
  "Done !"
end

# Register the function
server.register("update", namespace="metadata",
                 description="Update metadata",
                 usage="update song==foo,,album==bar,..",
                 icy_update)

# Rewrite metadata on the fly using a list of (target, rule).
# @category Source / Track Processing
# @param l  List of (target, value) rewriting rules
# @param ~insert_missing \
#           Treat track beginnings without metadata \
#           as having empty ones.
#

def rewrite_metadata(l, ~insert_missing=true, s)
  metadata.map(fun(m) -> list.map(fun(pair) -> begin
    let (label, pattern) = pair
    (label, pattern % m)
  end, l), insert_missing=insert_missing, s)
end
