--[[--
  Golden Fuckest SoundCloud Playlister for LVC

  Inspired the MarcusD product:
    https://gist.github.com/MarcuzD/c84b7599c40f4838e4e2
  Big Thanks and Big Love...
--]]--

local client_id = "bfc20bb261eff2b6848998b09c3d6954"

function probe()
	if string.match(vlc.access, "^https?$") ~= nil then
		if string.match(vlc.path, "(soundcloud%.com/[^/]+/sets/[^?/]+)") ~= nil then
			return true
		end
	end
	return false
end

function parse()
	local play_id
	local line
	line = vlc.readline()
	repeat
		play_id = string.match(line, "\"soundcloud://playlists:(%d+)\"")
		if play_id then
			break
		end
		line = vlc.readline()
	until (not line)
	if not play_id then return {} end
	local s, ejj = vlc.stream("http://api.soundcloud.com/playlists/" .. play_id .. ".json?client_id=" .. client_id)
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
			path = (v.stream_url .. "?client_id=" .. client_id),
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
