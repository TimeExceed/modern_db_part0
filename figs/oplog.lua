package.path = package.path .. ';lib/?.lua'
local luamp = require 'luamp'
local stream = require 'stream'
local table = require 'table'
local string = require 'string'

local SEG_WIDTH = 1
local SEG_HEIGHT = 0.8

local rects = stream
    .iterate(
        luamp.origin,
        function(x)
            return x + luamp.point(SEG_WIDTH, 0)
        end)
    :take(5)
    :map(function(x)
        return luamp.rectangle(x, SEG_WIDTH, SEG_HEIGHT)
    end)
    :collect()

local figs = {}

stream.from_list(rects)
    :drop(2)
    :map(function(x)
        local vertices = x:vertices()
        return luamp.line(vertices[1], vertices[4])
    end)
    :collect(figs)

stream.zip(
    stream.from_list({'n-2', 'n-1', 'n'}),
    stream.from_list(rects):drop(2))
    :map(function(x)
        local idx = x[1]
        local rect = x[2]
        return stream.from_list({
            luamp.text(
                rect:center(),
                luamp.directions.center,
                string.format('$\\text{op}_{%s}$', idx)),
            luamp.text(
                rect:vertices()[1],
                luamp.directions.top,
                string.format('$\\text{SN}_{%s}$', idx))})
    end)
    :flatten()
    :collect(figs)

local vs = {
    rects[1]:vertices()[1],
    rects[5]:vertices()[2],
    rects[5]:vertices()[3],
    rects[1]:vertices()[4]}
stream
    .zip(
        stream.from_list(vs),
        stream.from_list(vs)
            :chain(stream.from_list(vs))
            :drop(1))
    :map(function(x)
        return luamp.line(x[1], x[2])
    end)
    :collect(figs)

local t = luamp.text(
    luamp.centroid(rects[1]:vertices()[2], rects[1]:vertices()[3]),
    luamp.directions.center,
    '\\dots')
table.insert(figs, t)

print(luamp.figure(table.unpack(figs)))
