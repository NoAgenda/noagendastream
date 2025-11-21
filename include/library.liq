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
  gain = 3.
  ratio = 3.
  threshold = -15.
  target = -13.

  s = normalize(target=target, s)
  s = compress(gain=gain, ratio=ratio, threshold=threshold, s)
  s
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
  "Done !"
end

# Register the function
server.register("update", namespace="metadata",
                 description="Update metadata",
                 usage="update song==foo,,album==bar,..",
                 icy_update)

