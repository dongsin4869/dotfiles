local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local caffeinate = sbar.add("item", "widgets.caffeinate", {
  position = "right",
  icon = {
    string = icons.caffeinate.off,
    font = {
      style = settings.font.style_map["Regular"],
      size = 16.0,
    }
  },
  label = { drawing = false },
  update_freq = 30,
})

local function update_caffeinate_status()
  sbar.exec("pgrep -x caffeinate", function(result)
    local is_active = result and result ~= ""
    
    caffeinate:set({
      icon = {
        string = is_active and icons.caffeinate.on or icons.caffeinate.off
      },
    })
  end)
end

local function toggle_caffeinate()
  sbar.exec("pgrep -x caffeinate", function(result)
    local is_active = result and result ~= ""
    
    if is_active then
      sbar.exec("killall caffeinate", function()
        caffeinate:set({ icon = { string = icons.caffeinate.off } })
      end)
    else
      sbar.exec("screen -d -m caffeinate", function()
        caffeinate:set({ icon = { string = icons.caffeinate.on } })
      end)
    end
  end)
end

caffeinate:subscribe({"routine", "system_woke"}, update_caffeinate_status)

caffeinate:subscribe("mouse.clicked", toggle_caffeinate)

update_caffeinate_status()

sbar.add("bracket", "widgets.caffeinate.bracket", { caffeinate.name }, {
  background = { color = colors.bg1 }
})

sbar.add("item", "widgets.caffeinate.padding", {
  position = "right",
  width = settings.group_paddings
})