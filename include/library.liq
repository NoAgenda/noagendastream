# % -- include/library.liq -- %
# vim: ft=liq ts=4 sw=4 sts=2 et ai fdm=marker

####################################
# The server seeking function
# Seeks to a position in the stream
def seek(s,t) =
  t = float_of_string(default=0.,t)
  log("Seeking #{t} sec")
  ret = source.seek(s,t)
  "Seeked #{ret} seconds."
end

#####################
def audio_process(s)
  gain = interactive.float("compress.gain",3.)
  ratio = 3. # interactive.float("compress.ratio",3.)
  threshold = interactive.float("compress.threshold",-15.)

  target = interactive.float("norm.target",-13.)
  k_up = interactive.float("norm.kup",0.005)
  k_down = interactive.float("norm.kdn",0.1)

  s = normalize(target=target,k_up=k_up,k_down=k_down,s)
  s = compress(gain=gain,ratio=ratio,threshold=threshold,s)
  s
end
########################################
# Manually update icecast metadata via telnet
def icy_update(v) =
  # Parse the argument
  l = string.split(separator=",,",v)
  def split(l,v) =
    v = string.split(separator="==",v)
    if list.length(v) >= 2 then
      list.append(l,[(list.nth(v,0),list.nth(v,1))])
    else
      l
    end
  end
  meta = list.fold(split,[],l)

  def upd(h)
    icy.update_metadata(mount=streammount,
                        password=streampass,
                        host=h,
                        protocol="http",
                        port=80,
                        meta)
  end

  # Update metadata
  upd(nastream1)
  upd(nastream2)
  upd(nastream3)
  "Done !"
end

# Register the function
server.register("update",namespace="metadata",
                 description="Update metadata",
                 usage="update song==foo,,album==bar,..",
                 icy_update)

# Rewrite metadata on the fly using a list of (target,rule).
# @category Source / Track Processing
# @param l  List of (target,value) rewriting rules
# @param ~insert_missing \
#           Treat track beginnings without metadata \
#           as having empty ones.
def rewrite_metadata(l,~insert_missing=true,s)
  def map(m)
    def apply(x)
      label = fst(x)
      meta = snd(x)
      if list.mem_assoc(label,l) then
        pattern = l[label]
        (label,pattern % m)
      else
        (label,meta)
      end
    end
    m = list.map(apply,m)
    def add(m,x)
      label = fst(x)
      pattern = snd(x)
      # If m does not have (label,_), then it was
      # not processed previously, we have to
      # add it now..
      if not list.mem_assoc(label,m) then
        list.append(m,[(label,pattern % m)])
      else
        m
      end
    end
    list.fold(add,m,l)
  end
  map_metadata(map,insert_missing=insert_missing,s)
end
