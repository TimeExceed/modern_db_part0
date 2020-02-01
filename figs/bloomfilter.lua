package.path = package.path .. ';lib/?.lua'
local luamp = require 'luamp'
local stream = require 'stream'
local table = require 'table'

local figs = {}

local function bitmap()
    local width = 0.4
    local height = 0.4
    local rects = stream.iterate(
        luamp.origin,
        function(x)
            return x + luamp.point(width, 0)
        end)
        :map(function(c)
            return luamp.rectangle(c, width, height)
        end)
        :take(7)
        :collect()
    stream.from_list(rects)
        :map(function(x)
            local vertices = x:vertices()
            return luamp.line(vertices[1], vertices[4])
        end)
        :collect(figs)
    local b_center = luamp.centroid(rects[1]:vertices()[1], rects[#rects]:vertices()[3])
    local boundary = luamp.rectangle(b_center, width * #rects, height)
    table.insert(figs, boundary)
    return rects
end
local rects = bitmap()

local function key()
    local p = luamp.point(1, 1.5)
    stream.from_list({
        luamp.text(p, luamp.directions.top, '$k$'),
        luamp.arrow(p, rects[1]),
        luamp.arrow(p, rects[3]),
        luamp.arrow(p, rects[6]),
        luamp.text(luamp.point(0.2, 0.7), luamp.directions.center, '\\scriptsize $h_0(k)$'),
        luamp.text(luamp.point(1.2, 0.5), luamp.directions.center, '\\scriptsize $h_1(k)$'),
        luamp.text(luamp.point(1.8, 0.9), luamp.directions.center, '\\scriptsize $h_2(k)$'),
    })
        :collect(figs)
end
local key_p = key()

print(luamp.figure(table.unpack(figs)))
