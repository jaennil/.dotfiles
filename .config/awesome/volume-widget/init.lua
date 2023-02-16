local gears = require("gears")
local wibox = require("wibox")

-- capture returned output from a shell command
function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

-- read volume value(0%-100%) from system
local function get_volume()
    return os.capture("awk -F\"[][]\" '/dB/ { print $2 }' <(amixer sget Master)", true)
end

local function get_volume_state()
    return os.capture("amixer get Master", true)
end

local function gen_widget_text()
    local volume = get_volume()
    local volume_state = get_volume_state()
    local widget_text = ""

    if string.find(volume_state, "off") then
        widget_text = "mut"
    else
        widget_text = volume .. "%"
    end
    return "  <span foreground=\"green\">" .. widget_text .. "</span>".. " "
end

local volume_widget = wibox.widget.textbox()
volume_widget.font = "Nerd Fonts Sf Mono 8"
volume_widget.text = gen_widget_text()
volume_widget.set_align("right")
volume_widget:connect_signal("button::release", function(_, _, _, _)
    os.execute("amixer -q sset Master toggle")
end)

local function update_volume()
    volume_widget:set_markup(gen_widget_text())
end

local volume_timer = gears.timer({ timeout = 0.1})
volume_timer:connect_signal("timeout", function () update_volume() end)
volume_timer:start()

return setmetatable(volume_widget, { __call = function(_, ...) return volume_widget end })
