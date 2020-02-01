package.path = package.path .. ';lib/?.lua'
local luamp = require 'luamp'
local stream = require 'stream'
local table = require 'table'

local figs = {}

table.insert(
    figs,
    luamp.polygon({
        luamp.point(0.8, 0.7),
        luamp.point(0.5, 1.4),
        luamp.point(1.1, 2.8),
        luamp.point(2.2, 2.5),
        luamp.point(2.5, 1.1),
        luamp.point(1.2, 0.5)},
        {brush_color=luamp.colors.gray, pen_color=luamp.colors.invisible}))
stream
    .iterate(
        luamp.origin,
        function(x)
            return x + luamp.point(1, 0)
        end)
    :map(function(x)
        return luamp.line(
            x,
            x + luamp.point(0, 3),
            {line_style=luamp.line_styles.dashed})
    end)
    :take(4)
    :collect(figs)
stream
    .iterate(
        luamp.origin,
        function(x)
            return x + luamp.point(0, 1)
        end)
    :map(function(x)
        return luamp.line(
            x,
            x + luamp.point(3, 0),
            {line_style=luamp.line_styles.dashed})
    end)
    :take(4)
    :collect(figs)

print(luamp.figure(table.unpack(figs)))
