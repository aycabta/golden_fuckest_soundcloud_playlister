--[[--
  Golden Fuckest SoundCloud Playlister for VLC

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
	local url = "http://api.soundcloud.com/playlists/" .. play_id .. ".json?client_id=" .. client_id
	local s, ejj = vlc.stream(url)
	if s == nil then return {} end
	local json_data
	local chunk = s:read(4096)
	while chunk ~= nil do
		if json_data == nil then
			json_data = chunk
		else
			json_data = json_data .. chunk
		end
		chunk = s:read(4096)
	end
	if not json_data then return {} end
	local dkjson = require "dkjson"
	local json = dkjson.decode(json_data)
	local buf = {}
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
