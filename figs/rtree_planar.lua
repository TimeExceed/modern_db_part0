package.path = package.path .. ';lib/?.lua'
local luamp = require 'luamp'
local stream = require 'stream'
local table = require 'table'

local a = luamp.point(0, -1)
local b = luamp.point(1, 0)
local c = luamp.point(0.5, -1.5)
local d = luamp.point(1.5, -2)
local e = luamp.point(2, -1.75)
local f = luamp.point(3, -2.5)
local g = luamp.point(2.75, 0)
local h = luamp.point(3.25, -0.5)

local figs = {}

table.insert(figs, luamp.text(a, luamp.directions.left, '$a$'))
table.insert(figs, luamp.text(b, luamp.directions.top, '$b$'))
table.insert(figs, luamp.text(c, luamp.directions.top, '$c$'))
table.insert(figs, luamp.text(d, luamp.directions.bottom, '$d$'))
table.insert(figs, luamp.text(e, luamp.directions.top_right, '$e$'))
table.insert(figs, luamp.text(f, luamp.directions.bottom, '$f$'))
table.insert(figs, luamp.text(g, luamp.directions.top, '$g$'))
table.insert(figs, luamp.text(h, luamp.directions.right, '$h$'))

stream.from_list({a, b, c, d, e, f, g, h})
    :map(function(x)
        return luamp.bullet(x)
    end)
    :collect(figs)

local function bbox(...)
    local ps = table.pack(...)
    local minx = stream.from_list(ps)
        :map(function(v)
            return v.x
        end)
        :accumulate(function(v, w)
            return luamp.min(v, w)
        end)
        :last()
    local miny = stream.from_list(ps)
        :map(function(v)
            return v.y
        end)
        :accumulate(function(v, w)
            return luamp.min(v, w)
        end)
        :last()
    local maxx = stream.from_list(ps)
        :map(function(v)
            return v.x
        end)
        :accumulate(function(v, w)
            return luamp.max(v, w)
        end)
        :last()
    local maxy = stream.from_list(ps)
        :map(function(v)
            return v.y
        end)
        :accumulate(function(v, w)
            return luamp.max(v, w)
        end)
        :last()
    return luamp.rectangle(luamp.point((minx+maxx)/2, (miny+maxy)/2), maxx-minx, maxy-miny)
end

local whole_box = bbox(a, b, c, d, e, f, g, h)
table.insert(figs, whole_box)

local left = bbox(a, b, c, d)
local left = luamp.rectangle(
    left:center(),
    left:width(),
    left:height(),
    {pen_color=luamp.colors.red})
table.insert(figs, left)

local left_left = bbox(a, b)
local left_left = luamp.rectangle(
    left_left:center(),
    left_left:width(),
    left_left:height(),
    {pen_color=luamp.colors.blue})
table.insert(figs, left_left)

local left_right = bbox(c, d)
local left_right = luamp.rectangle(
    left_right:center(),
    left_right:width(),
    left_right:height(),
    {pen_color=luamp.colors.blue})
table.insert(figs, left_right)

local right = bbox(e, f, g, h)
local right = luamp.rectangle(
    right:center(),
    right:width(),
    right:height(),
    {pen_color=luamp.colors.red})
table.insert(figs, right)

local right_left = bbox(e, f)
local right_left = luamp.rectangle(
    right_left:center(),
    right_left:width(),
    right_left:height(),
    {pen_color=luamp.colors.blue})
table.insert(figs, right_left)

local right_right = bbox(g, h)
local right_right = luamp.rectangle(
    right_right:center(),
    right_right:width(),
    right_right:height(),
    {pen_color=luamp.colors.blue})
table.insert(figs, right_right)

print(luamp.figure(table.unpack(figs)))
