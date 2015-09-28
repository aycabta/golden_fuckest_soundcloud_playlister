--[[--
  SonundCloud set (playlist-thingy) parser
  Made by MarcusD
  
  This is a VLC playlist plugin to be able to play SoundCloud sets
  An example set link: https://soundcloud.com/shanemesa/sets/mother4soundtrack
  
  My GitHub page:     https://github.com/MarcuzD
  My Youtube channel: https://youtube.com/user/mCucc
--]]--

local cid = "bfc20bb261eff2b6848998b09c3d6954"

-- Probe function.
function probe()
    return ( vlc.access == "https" or vlc.access == "http" )
        and string.match( vlc.path, "(soundcloud%.com/[^/]+/sets/[^?/]+)" )
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
    line = nil
    local new = s:readline()
    while new ~= nil do
      if line == nil then
        line = new
      else
        line = line .. new
      end
      new = s:readline()
    end
    if not line then return {} end
    json = require "dkjson"
    json = json.decode(line)
    buf = {}
    for k,v in pairs(json.tracks) do
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
