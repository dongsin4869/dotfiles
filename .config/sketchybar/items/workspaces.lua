local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local app_images = require("helpers.app_images")

local function image_path(name, focused)
	local suffix = focused and "" or "_dim"
	return os.getenv("HOME") .. "/.config/sketchybar/images/" .. name .. suffix .. ".png"
end

local query_workspaces =
	"aerospace list-workspaces --all --format '%{workspace}%{monitor-appkit-nsscreen-screens-id}' --json"

-- Root is used to handle event subscriptions
local root = sbar.add("item", { drawing = false })
local workspaces = {}
-- Per workspace, an item showing the icon image of each app in app_images
local workspace_images = {}

local function withWindows(f)
	local open_windows = {}
	local open_images = {}
	-- Include the window ID in the query so we can track unique windows
	local get_windows =
		"aerospace list-windows --monitor all --format '%{workspace}%{app-name}%{app-bundle-id}%{window-id}' --json"
	local query_visible_workspaces =
		"aerospace list-workspaces --visible --monitor all --format '%{workspace}%{monitor-appkit-nsscreen-screens-id}' --json"
	local get_focus_workspaces = "aerospace list-workspaces --focused"
	sbar.exec(get_windows, function(workspace_and_windows)
		-- Use a set to track unique window IDs
		local processed_windows = {}

		for _, entry in ipairs(workspace_and_windows) do
			local workspace_index = entry.workspace
			local app = entry["app-name"]
			local bundle_id = entry["app-bundle-id"]
			local window_id = entry["window-id"]

			if app_images[bundle_id] then
				if open_images[workspace_index] == nil then
					open_images[workspace_index] = {}
				end
				open_images[workspace_index][bundle_id] = true
			elseif not processed_windows[window_id] then
				-- Only process each window ID once
				processed_windows[window_id] = true

				if open_windows[workspace_index] == nil then
					open_windows[workspace_index] = {}
				end

				-- Check if this app is already in the list for this workspace
				local app_exists = false
				for _, existing_app in ipairs(open_windows[workspace_index]) do
					if existing_app == app then
						app_exists = true
						break
					end
				end

				-- Only add the app if it's not already in the list
				if not app_exists then
					table.insert(open_windows[workspace_index], app)
				end
			end
		end

		sbar.exec(get_focus_workspaces, function(focused_workspaces)
			sbar.exec(query_visible_workspaces, function(visible_workspaces)
				local args = {
					open_windows = open_windows,
					open_images = open_images,
					focused_workspaces = focused_workspaces,
					visible_workspaces = visible_workspaces,
				}
				f(args)
			end)
		end)
	end)
end

local function updateWindow(workspace_index, args)
	local open_windows = args.open_windows[workspace_index]
	local focused_workspaces = args.focused_workspaces
	local visible_workspaces = args.visible_workspaces

	if open_windows == nil then
		open_windows = {}
	end

	local icon_line = ""
	local no_app = true
	for i, open_window in ipairs(open_windows) do
		no_app = false
		local app = open_window
		local lookup = app_icons[app]
		local icon = ((lookup == nil) and app_icons["Default"] or lookup)
		icon_line = icon_line .. " " .. icon
	end

	local open_images = args.open_images[workspace_index] or {}
	local has_image = next(open_images) ~= nil
	if has_image then
		no_app = false
	end
	for bundle_id, image in pairs(workspace_images[workspace_index]) do
		image:set({ drawing = open_images[bundle_id] == true })
	end
	-- Pull the image items up against the glyphs, or the index if there are none
	workspaces[workspace_index]:set({
		label = {
			drawing = not (has_image and icon_line == ""),
			padding_right = has_image and 0 or 12,
		},
	})

	sbar.animate("tanh", 10, function()
		for i, visible_workspace in ipairs(visible_workspaces) do
			if no_app and workspace_index == visible_workspace["workspace"] then
				local monitor_id = visible_workspace["monitor-appkit-nsscreen-screens-id"]
				icon_line = " —"
				workspaces[workspace_index]:set({
					drawing = true,
					label = { string = icon_line },
					display = monitor_id,
				})
				return
			end
		end
		if no_app and workspace_index ~= focused_workspaces then
			workspaces[workspace_index]:set({
				drawing = false,
			})
			return
		end
		if no_app and workspace_index == focused_workspaces then
			icon_line = " —"
			workspaces[workspace_index]:set({
				drawing = true,
				label = { string = icon_line },
			})
		end

		workspaces[workspace_index]:set({
			drawing = true,
			label = { string = icon_line },
		})
	end)
end

local function updateWindows()
	withWindows(function(args)
		for workspace_index, _ in pairs(workspaces) do
			updateWindow(workspace_index, args)
		end
	end)
end

local function updateWorkspaceMonitor()
	local workspace_monitor = {}
	sbar.exec(query_workspaces, function(workspaces_and_monitors)
		for _, entry in ipairs(workspaces_and_monitors) do
			local space_index = entry.workspace
			local monitor_id = math.floor(entry["monitor-appkit-nsscreen-screens-id"])
			workspace_monitor[space_index] = monitor_id
		end
		for workspace_index, _ in pairs(workspaces) do
			workspaces[workspace_index]:set({
				display = workspace_monitor[workspace_index],
			})
			for _, image in pairs(workspace_images[workspace_index]) do
				image:set({ display = workspace_monitor[workspace_index] })
			end
		end
	end)
end

sbar.exec(query_workspaces, function(workspaces_and_monitors)
	for _, entry in ipairs(workspaces_and_monitors) do
		local workspace_index = entry.workspace

		local workspace = sbar.add("item", {
			background = {
				drawing = false, -- Drawn by the bracket below
			},
			click_script = "aerospace workspace " .. workspace_index,
			drawing = false, -- Hide all items at first
			icon = {
				color = colors.with_alpha(colors.white, 0.3),
				drawing = true,
				font = { family = settings.font.numbers },
				highlight_color = colors.white,
				padding_left = 5,
				padding_right = 4,
				string = workspace_index,
			},
			label = {
				color = colors.with_alpha(colors.white, 0.3),
				drawing = true,
				font = "sketchybar-app-font:Regular:16.0",
				highlight_color = colors.white,
				padding_left = 2,
				padding_right = 12,
				y_offset = -1,
			},
		})

		workspaces[workspace_index] = workspace

		workspace_images[workspace_index] = {}
		local members = { workspace.name }
		for bundle_id, name in pairs(app_images) do
			local image = sbar.add("item", {
				background = {
					color = colors.transparent,
					border_width = 0,
					drawing = true,
					image = {
						string = image_path(name, false),
						scale = 0.27,
						border_width = 0,
						corner_radius = 0,
					},
				},
				click_script = "aerospace workspace " .. workspace_index,
				drawing = false,
				icon = { drawing = false },
				label = { drawing = false },
				padding_left = 0,
				padding_right = 5,
			})
			workspace_images[workspace_index][bundle_id] = image
			table.insert(members, image.name)
		end

		-- Draw the pill behind the workspace and its image items together
		sbar.add("bracket", members, {
			background = { color = colors.bg1 },
		})

		workspace:subscribe("aerospace_workspace_change", function(env)
			local focused_workspace = env.FOCUSED_WORKSPACE
			local is_focused = focused_workspace == workspace_index

			sbar.animate("tanh", 10, function()
				workspace:set({
					icon = { highlight = is_focused },
					label = { highlight = is_focused },
					blur_radius = 30,
				})
			end)
			for bundle_id, image in pairs(workspace_images[workspace_index]) do
				image:set({ background = { image = { string = image_path(app_images[bundle_id], is_focused) } } })
			end
		end)
	end

	-- Initial setup
	updateWindows()
	updateWorkspaceMonitor()

	-- Subscribe to window creation/destruction events
	root:subscribe("aerospace_workspace_change", function()
		updateWindows()
	end)

	-- Subscribe to front app changes too
	root:subscribe("front_app_switched", function()
		updateWindows()
	end)

	root:subscribe("display_change", function()
		updateWorkspaceMonitor()
		updateWindows()
	end)

	sbar.exec("aerospace list-workspaces --focused", function(focused_workspace)
		local focused_workspace = focused_workspace:match("^%s*(.-)%s*$")
		workspaces[focused_workspace]:set({
			icon = { highlight = true },
			label = { highlight = true },
		})
		for bundle_id, image in pairs(workspace_images[focused_workspace]) do
			image:set({ background = { image = { string = image_path(app_images[bundle_id], true) } } })
		end
	end)
end)
