local icons = require("icons")
local colors = require("colors")

local whitelist = { ["Spotify"] = true, ["Music"] = true }

local media_cover = sbar.add("item", "media_cover", {
	position = "right",
	background = {
		image = {
			string = "media.artwork",
			scale = 0.85,
		},
		color = colors.transparent,
	},
	label = { drawing = false },
	icon = { drawing = false },
	drawing = false,
	updates = true,
	update_freq = 2,
	popup = {
		align = "center",
		horizontal = true,
	},
})

local media_artist = sbar.add("item", "media_artist", {
	position = "right",
	drawing = false,
	padding_left = 3,
	padding_right = 0,
	icon = { drawing = false },
	label = {
		font = { size = 9 },
		color = colors.with_alpha(colors.white, 0.6),
		max_chars = 18,
		y_offset = 6,
	},
})

local media_title = sbar.add("item", "media_title", {
	position = "right",
	drawing = false,
	padding_left = 3,
	padding_right = 0,
	icon = { drawing = false },
	label = {
		font = { size = 11 },
		max_chars = 16,
		y_offset = -5,
	},
})

sbar.add("item", {
	position = "popup." .. media_cover.name,
	icon = { string = icons.media.back },
	label = { drawing = false },
	click_script = "osascript -e 'tell application \"Spotify\" to previous track'",
})
sbar.add("item", {
	position = "popup." .. media_cover.name,
	icon = { string = icons.media.play_pause },
	label = { drawing = false },
	click_script = "osascript -e 'tell application \"Spotify\" to playpause'",
})
sbar.add("item", {
	position = "popup." .. media_cover.name,
	icon = { string = icons.media.forward },
	label = { drawing = false },
	click_script = "osascript -e 'tell application \"Spotify\" to next track'",
})

local function is_spotify_running()
	local handle = io.popen("ps aux | grep -i '/Applications/Spotify.app/Contents/MacOS/Spotify' | grep -v grep")
	if not handle then
		return false
	end
	local result = handle:read("*a")
	handle:close()
	return result and result ~= ""
end

local function get_spotify_info(field)
	if not is_spotify_running() then
		return ""
	end
	
	local script =
		string.format("osascript -e 'tell application \"Spotify\" to %s of current track' 2>/dev/null", field)
	local handle = io.popen(script)
	if not handle then
		return ""
	end
	local result = handle:read("*a")
	handle:close()
	return result and result:gsub("%s+$", "") or ""
end

local function update_media()
	local playing = false
	local paused = false
	local show_widget = false
	local artist = ""
	local title = ""

	-- Check if Spotify is running first
	if is_spotify_running() then
		-- Check Spotify state
		local handle = io.popen("osascript -e 'tell application \"Spotify\" to player state' 2>/dev/null")
		if handle then
			local state = handle:read("*a"):gsub("%s+", "")
			handle:close()

			if state == "playing" then
				playing = true
				show_widget = true
				artist = get_spotify_info("artist")
				title = get_spotify_info("name")
			elseif state == "paused" then
				paused = true
				show_widget = true
				artist = get_spotify_info("artist")
				title = get_spotify_info("name")
				-- Add paused indicator
				title = "⏸ " .. title
			end
		end
	end

	media_artist:set({ drawing = show_widget, label = { string = artist } })
	media_title:set({ drawing = show_widget, label = { string = title } })
	media_cover:set({ drawing = show_widget })

	if not show_widget then
		media_cover:set({ popup = { drawing = false } })
	end
end

-- Media change event (fallback)
media_cover:subscribe("media_change", function(env)
	if whitelist[env.INFO.app] then
		local show_widget = (env.INFO.state == "playing" or env.INFO.state == "paused")
		local artist = env.INFO.artist or get_spotify_info("artist")
		local title = env.INFO.title or get_spotify_info("name")

		if env.INFO.state == "paused" then
			title = "⏸ " .. title
		end

		media_artist:set({ drawing = show_widget, label = { string = artist } })
		media_title:set({ drawing = show_widget, label = { string = title } })
		media_cover:set({ drawing = show_widget })

		if not show_widget then
			media_cover:set({ popup = { drawing = false } })
		end
	end
end)

-- Regular updates
media_cover:subscribe("routine", update_media)

media_cover:subscribe("mouse.clicked", function(env)
	media_cover:set({ popup = { drawing = "toggle" } })
end)

media_title:subscribe("mouse.exited.global", function(env)
	media_cover:set({ popup = { drawing = false } })
end)

-- Click on title/artist to play/pause
media_title:subscribe("mouse.clicked", function()
	os.execute("osascript -e 'tell application \"Spotify\" to playpause' 2>/dev/null &")
	sbar.delay(0.5, update_media)
end)

media_artist:subscribe("mouse.clicked", function()
	os.execute("osascript -e 'tell application \"Spotify\" to playpause' 2>/dev/null &")
	sbar.delay(0.5, update_media)
end)

-- Initial update
update_media()
