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

local volume_widget = {}

function volume_widget:new(args)
    return setmetatable({}, { __index = self }):init(args)
end

function volume_widget:init(args)
    self.widget = wibox.widget.textbox()
    self.widget.font = "Nerd Fonts Sf Mono 8"
    self.widget.markup = self:gen_widget_text()
    self.widget.set_align("right")
    self.widget:connect_signal("button::release", function(_, _, _, _)
        os.execute("pactl set-sink-mute @DEFAULT_SINK@ toggle")
    end)
    self.timer = gears.timer({ timeout = 0.1 })
    self.timer:connect_signal("timeout", function() self:update_volume() end)
    self.timer:start()
    return self
end

-- read volume value(0%-100%) from system
function volume_widget:get_volume()
    local pactl = os.capture("pactl get-sink-volume @DEFAULT_SINK@", true)
    local volume = string.sub(pactl, string.find(pactl, "%d+%%"))
    return volume
end

function volume_widget:is_volume_muted()
    local state = os.capture("pactl get-sink-mute @DEFAULT_SINK@", true)
    if string.find(state, "yes") then
        return true
    else
        return false
    end
end

function volume_widget:gen_widget_text()
    local volume = self:get_volume()
    local widget_text = ""

    if self:is_volume_muted() then
        widget_text = "<span foreground=\"red\">mut</span>"
    else
        widget_text = "<span foreground=\"pink\">" .. volume .. "</span>"
    end
    return "  " .. widget_text .. " "
end

function volume_widget:update_volume()
    self.widget:set_markup(self:gen_widget_text())
end

return setmetatable(volume_widget, { __call = volume_widget.new, })
