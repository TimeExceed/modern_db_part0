package.path = package.path .. ';lib/?.lua'
local luamp = require 'luamp'
local stream = require 'stream'
local table = require 'table'
local skiplist = require 'skiplist_lib'

local figs = {}

local circles = skiplist.draw_doc_chain(figs, luamp.origin, {'1', '2', '3', '4', '5', '6', '7', '8', '9'})
local ps = {
    circles[1]:center() + luamp.point(0, 1.6),
    circles[1]:center() + luamp.point(0, 1.1),
    circles[5]:center() + luamp.point(0, 1.1),
    circles[5]:center() + luamp.point(0, 0.6),
    circles[7]:center() + luamp.point(0, 0.6),
    circles[7],
    circles[8],
}
stream
    .zip(
        stream.from_list(ps),
        stream.from_list(ps):drop(1))
    :map(function(x)
        return luamp.line(x[1], x[2], {pen_color=luamp.colors.red})
    end)
    :collect(figs)

print(luamp.figure(table.unpack(figs)))
