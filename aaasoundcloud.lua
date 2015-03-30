--[[--
  SonundCloud set (playlist-thingy) parser
  Made by MarcusD
  
  This is a VLC playlist plugin to be able to play SoundCloud sets
  An example set link: https://soundcloud.com/shanemesa/sets/mother4soundtrack
  
  My GitHub page:     https://github.com/MarcuzD
  My Youtube channel: https://youtube.com/user/mCucc
--]]--

-- SoundCloud ClientID
local cid = "b45b1aa10f1ac2941910a7f0d10f8e28"

-- Probe function.
function probe()
    return ( vlc.access == "https" or vlc.access == "http" )
        and string.match( vlc.path, "(soundcloud%.com/[^/]+/sets/[^?/]+)" )
end

-- http://stackoverflow.com/questions/5958818/loading-serialized-data-into-a-table
function tf(s) 
  t={}
  f, err=loadstring(s)
  if f == nil then error(err) end
  setfenv(f,t)
  f()
  return t
end

-- Parse function.
function parse()
    line = vlc.readline()
    if not line then return {} end
    plyid = string.match(line, "\"soundcloud://playlists:(%d+)\"")
    if not plyid then return {} end
    local s, ejj = vlc.stream("http://api.soundcloud.com/playlists/" .. plyid .. ".json?client_id=" .. cid)
    if s == nil then return {} end
    local buf = {}
    line = s:readline()
    if not line then return {} end
    line = line:gsub("%[", "{"):gsub("%]", "}"):gsub("([{,])\"(.-)\":", "%1[\"%2\"]=")
    strr = tf("main=" .. line)
    buf = {}
    for k,v in pairs(strr.main.tracks) do
      buf[#buf + 1 ] =
          {
            path = (v.stream_url .. "?client_id=" .. cid),
            name = v.title,
            arturl = (v.artwork_url and v.artwork_url or v.user.artwork_url),
            title = v.title,
            artist = (v.user.username .. " (" .. v.user.permalink.. ")"),
            genre = v.genre,
            copyright = v.license,
            description = v.description,
            date = v.created_at,
            url = vlc.access .. "://" .. v.permalink_url,
            meta = 
            {
              ["tag list"] = v.tag_list,
              ["creation time"] = v.created_at
            }
          }
    end
    return buf
end
