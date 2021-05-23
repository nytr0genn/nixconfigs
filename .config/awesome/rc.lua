-- awesome 3.2 configuration file by xcession
-- last update: 2009/03/22

--------------------------------------------------------------------------------
--{{{ Imports

-- Standard awesome library
require("awful")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

--}}}
--------------------------------------------------------------------------------
--{{{ Theme!

beautiful.init(awful.util.getdir("config") .. "/theme")

beautiful.taglist_squares_sel       = awful.util.getdir("config") .. "/taglist/squarefw.png"
beautiful.taglist_squares_unsel     = awful.util.getdir("config") .. "/taglist/squarew.png"
beautiful.tasklist_floating_icon    = awful.util.getdir("config") .. "/tasklist/floatingw.png"
beautiful.awesome_icon              = awful.util.getdir("config") .. "/icons/awesome16.png"

beautiful.menu_submenu_icon         = awful.util.getdir("config") .. "/icons/submenu.png"

use_titlebar = false

--}}}
-------------------------------------------------------------------------------------
--{{{ Load functions

loadfile(awful.util.getdir("config") .. "/functions.lua")()

--}}}
--------------------------------------------------------------------------------
--{{{ Variables

-- Default modkey
modkey = "Mod4"

-- This is used later as the default terminal and editor to run
terminal = "urxvt"

layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    awful.layout.suit.floating
}

defaultLayout = layouts[3]

-- Apps that should be forced floating
floatapps =
{
    -- by class
    ["MPlayer"]     = true,
    ["Gimp"]        = true,
    -- by instance
    ["mocp"]        = true
}

-- App tags
apptags =
{
    -- ["Firefox"]  = { screen = 1, tag = 2 },
    -- ["mocp"]     = { screen = 2, tag = 4 },
}

--}}}
--------------------------------------------------------------------------------
--{{{ Menu
-- Popup menu when we rightclick the desktop

-- Submenu
awesomemenu = {
    { "restart", awesome.restart },
    { "quit", awesome.quit }
}
-- Main menu
mainmenu = awful.menu.new({
    items = {
        { "awesome", awesomemenu, beautiful.awesome_icon },
        { "open terminal", terminal }
    }
})

--}}}
--------------------------------------------------------------------------------
-- {{{ Tags

tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = {}
    -- Give the first 3 tag special names
    --tags[s][1] = awful.layout.set(defaultLayout, "Terminal")
    --tags[s][2] = awful.layout.set(defaultLayout, "Web")
    -- Put them on the screen
    --for tagnumber = 1, 2 do
    --    tags[s][tagnumber].screen = s
    --	awful.layout.set(defaultLayout, tags[s][tagnumber])
    --end
    -- Automatically name the next 6 tags after their tag number and put them on the screen
    for tagnumber = 1, 6 do
        tags[s][tagnumber] = tag(tagnumber)
        -- Add tags to screen one by one
	tags[s][tagnumber].screen = s
	awful.layout.set(defaultLayout, tags[s][tagnumber])
    end
    -- Select at least one tag
    tags[s][1].selected = true
end

-- }}}
-------------------------------------------------------------------------------------
--{{{ Widgets

-- Separator icon
separator = widget({ type = "imagebox", align = "right" })
separator.image = image(awful.util.getdir("config") .. "/icons/separator.png")

-- Awesome release
awesome_release = widget({ type = "textbox", align = "right" })
awesome_release.text = "<b><small> " .. AWESOME_RELEASE .. " </small></b>"

-- Create a systray
systray = widget({ type = "systray", align = "right" })

-- Create a clock widget
clockwidget = widget({ type = "textbox", align = "right" })

-- Create a battery widget
batteryicon = widget({ type = "imagebox", align = "right" })
batteryicon.image = image(awful.util.getdir("config") .. "/icons/batteryw.png")
batterywidget = widget({ type = "textbox", align = "right" })
batteryInfo("BAT0")

-- Create a wibox for each screen and add it
statusbar = {}
promptbox = {}
layouticon = {}
taglist = {}
-- Initialize which buttons do what when clicking the taglist
taglist.buttons =   {
                        button({ }, 1, awful.tag.viewonly),
                        button({ modkey }, 1, awful.client.movetotag),
                        button({ }, 3, function (tag) tag.selected = not tag.selected end),
                        button({ modkey }, 3, awful.client.toggletag),
                        button({ }, 4, awful.tag.viewnext),
                        button({ }, 5, awful.tag.viewprev)
                    }

tasklist = {}
-- Initialize which buttons do what when clicking the tasklist
tasklist.buttons =  {
			button({ }, 1, function (c)
			                  if not c:isvisible() then
					  awful.tag.viewonly(c:tags()[1])
			               end
                                          client.focus = c
                                          c:raise()
                                       end),
                        button({ }, 3, function () if instance then instance:hide() end instance = awful.menu.clients({ width=250 }) end),
                        button({ }, 4, function ()
                                          awful.client.focus.byidx(1)
                                          if client.focus then client.focus:raise() end
                                       end),
                        button({ }, 5, function ()
                                          awful.client.focus.byidx(-1)
                                          if client.focus then client.focus:raise() end
                                       end)
		    }

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    promptbox[s] = widget({ type = "textbox", align = "left" })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    layouticon[s] = widget({ type = "imagebox", align = "right" })
    layouticon[s]:buttons({ button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                            button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                            button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                            button({ }, 5, function () awful.layout.inc(layouts, -1) end) })
    -- Create a taglist widget
    taglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, taglist.buttons)

    -- Create a tasklist widget
    tasklist[s] = awful.widget.tasklist.new(function(c)
                                                  return awful.widget.tasklist.label.currenttags(c, s)
                                              end, tasklist.buttons)

    -- Create the wibox
    statusbar[s] = wibox({ position = "top", height = "16", fg = beautiful.fg_normal, bg = beautiful.bg_normal })
    -- Add widgets to the wibox - order matters
    statusbar[s].widgets = {
                                taglist[s],
				awesome_release,
                                layouticon[s],
                                tasklist[s],
                                promptbox[s],
                                separator,
				batteryicon,
                                batterywidget,
                                separator,
                                clockwidget,
                                s == 1 and systray or nil
                            }
    statusbar[s].screen = s
end

--}}}
--------------------------------------------------------------------------------
--{{{ Bindings

-- {{{ Mouse bindings
root.buttons({
    button({ }, 3, function () mainmenu:toggle() end),
    button({ }, 4, awful.tag.viewnext),
    button({ }, 5, awful.tag.viewprev)
})
-- }}}

-- {{{ Key bindings
globalkeys =
{
    key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    key({ modkey,           }, "Escape", awful.tag.history.restore),

    key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end),
    key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end),
    key({ modkey, "Control" }, "j", function () awful.screen.focus( 1)       end),
    key({ modkey, "Control" }, "k", function () awful.screen.focus(-1)       end),
    key({ modkey,           }, "u", awful.client.urgent.jumpto),
    key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    key({ modkey, "Control" }, "r", awesome.restart),
    key({ modkey, "Shift"   }, "q", awesome.quit),

    key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    key({ modkey }, "F1",
        function ()
            awful.prompt.run({ prompt = "Run: " },
            promptbox[mouse.screen],
            awful.util.spawn, awful.completion.bash,
            awful.util.getdir("cache") .. "/history")
        end),

    key({ modkey }, "F4",
        function ()
            awful.prompt.run({ prompt = "Run Lua code: " },
            promptbox[mouse.screen],
            awful.util.eval, awful.prompt.bash,
            awful.util.getdir("cache") .. "/history_eval")
        end),
}

-- Client awful tagging: this is useful to tag some clients and then do stuff like move to tag on them
clientkeys =
{
    key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    key({ modkey }, "t", awful.client.togglemarked),
    key({ modkey,}, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
}

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

for i = 1, keynumber do
    table.insert(globalkeys,
        key({ modkey }, i,
            function ()
                local screen = mouse.screen
                if tags[screen][i] then
                    awful.tag.viewonly(tags[screen][i])
                end
            end))
    table.insert(globalkeys,
        key({ modkey, "Control" }, i,
            function ()
                local screen = mouse.screen
                if tags[screen][i] then
                    tags[screen][i].selected = not tags[screen][i].selected
                end
            end))
    table.insert(globalkeys,
        key({ modkey, "Shift" }, i,
            function ()
                if client.focus and tags[client.focus.screen][i] then
                    awful.client.movetotag(tags[client.focus.screen][i])
                end
            end))
    table.insert(globalkeys,
        key({ modkey, "Control", "Shift" }, i,
            function ()
                if client.focus and tags[client.focus.screen][i] then
                    awful.client.toggletag(tags[client.focus.screen][i])
                end
            end))
end

for i = 1, keynumber do
    table.insert(globalkeys, key({ modkey, "Shift" }, "F" .. i,
                   function ()
                       local screen = mouse.screen
                       if tags[screen][i] then
                           for k, c in pairs(awful.client.getmarked()) do
                               awful.client.movetotag(tags[screen][i], c)
                           end
                       end
                   end))
end

-- Set keys
root.keys(globalkeys)

--}}}
--------------------------------------------------------------------------------
--{{{ Hooks

-- Hook function to execute when focusing a client.
awful.hooks.focus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_focus
    end
end)

-- Hook function to execute when unfocusing a client.
awful.hooks.unfocus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_normal
    end
end)

-- Hook function to execute when marking a client
awful.hooks.marked.register(function (c)
    c.border_color = beautiful.border_marked
end)

-- Hook function to execute when unmarking a client.
awful.hooks.unmarked.register(function (c)
    c.border_color = beautiful.border_focus
end)

-- Hook function to execute when the mouse enters a client.
awful.hooks.mouse_enter.register(function (c)
    -- Sloppy focus, but disabled for magnifier layout
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- Hook function to execute when a new client appears.
awful.hooks.manage.register(function (c, startup)
    -- If we are not managing this application at startup,
    -- move it to the screen where the mouse is.
    -- We only do it for filtered windows (i.e. no dock, etc).
    if not startup and awful.client.focus.filter(c) then
        c.screen = mouse.screen
    end

    if use_titlebar then
        -- Add a titlebar
        awful.titlebar.add(c, { modkey = modkey })
    end
    -- Add mouse bindings
    c:buttons({
        button({ }, 1, function (c) client.focus = c; c:raise() end),
        button({ modkey }, 1, awful.mouse.client.move),
        button({ modkey }, 3, awful.mouse.client.resize)
    })
    -- New client may not receive focus
    -- if they're not focusable, so set border anyway.
    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal

    -- Check if the application should be floating.
    local cls = c.class
    local inst = c.instance
    if floatapps[cls] then
        awful.client.floating.set(c, floatapps[cls])
    elseif floatapps[inst] then
        awful.client.floating.set(c, floatapps[inst])
    end

    -- Check application->screen/tag mappings.
    local target
    if apptags[cls] then
        target = apptags[cls]
    elseif apptags[inst] then
        target = apptags[inst]
    end
    if target then
        c.screen = target.screen
        awful.client.movetotag(tags[target.screen][target.tag], c)
    end

    -- Do this after tag mapping, so you don't see it on the wrong tag for a split second.
    client.focus = c

    -- Set key bindings
    c:keys(clientkeys)

    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- awful.client.setslave(c)

    -- Honor size hints: if you want to drop the gaps between windows, set this to false.
    -- c.size_hints_honor = false
end)

-- Hook function to execute when arranging the screen.
-- (tag switch, new client, etc)
awful.hooks.arrange.register(function (screen)
    local layout = awful.layout.getname(awful.layout.get(screen))
    if layout then
        layouticon[screen].image = image(awful.util.getdir("config") .. "/icons/layouts/" .. awful.layout.getname(awful.layout.get(screen)) .. "w.png")
    else
        layouticon[screen].image = nil
    end

    -- Give focus to the latest client in history if no window has focus
    -- or if the current window is a desktop or a dock one.
    if not client.focus then
        local c = awful.client.focus.history.get(screen, 0)
        if c then client.focus = c end
    end

    -- Uncomment if you want mouse warping
    --[[
    if client.focus then
        local c_c = client.focus:fullgeometry()
        local m_c = mouse.coords()

        if m_c.x < c_c.x or m_c.x >= c_c.x + c_c.width or
            m_c.y < c_c.y or m_c.y >= c_c.y + c_c.height then
            if table.maxn(m_c.buttons) == 0 then
                mouse.coords({ x = c_c.x + 5, y = c_c.y + 5})
            end
        end
    end
    ]]
end)

-- Timed hooks for the widget functions
-- 1 second
awful.hooks.timer.register(1, function ()
    clockwidget.text = " " .. os.date() .. " "
end)

-- 20 seconds
awful.hooks.timer.register(20, function ()
    batteryInfo("BAT0")
end)

-- }}}
