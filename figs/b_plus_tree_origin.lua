package.path = package.path .. ';lib/?.lua'
local table = require 'table'
local io = require 'io'
local stream = require 'stream'
local luamp = require 'luamp'
local btree = require 'b_plus_tree'

local figs = {}
local levels = btree.levels

stream.from_list(levels)
    :map(function(x)
        return stream.from_list(x)
    end)
    :flatten()
    :collect(figs)

stream.from_list({
    luamp.arrow(
        levels[1][1].ptr_bullets[1],
        levels[2][1]:vertices()[1]),
    luamp.arrow(
        levels[1][1].ptr_bullets[2],
        levels[2][2]:vertices()[1]),
    luamp.arrow(
        levels[2][1].ptr_bullets[1],
        levels[3][1]:vertices()[1]),
    luamp.arrow(
        levels[2][1].ptr_bullets[2],
        levels[3][2]:vertices()[1]),
    luamp.arrow(
        levels[2][1].ptr_bullets[3],
        levels[3][3]:vertices()[1]),
    luamp.arrow(
        levels[2][2].ptr_bullets[1],
        levels[3][4]:vertices()[1]),
    luamp.arrow(
        levels[2][2].ptr_bullets[2],
        levels[3][5]:vertices()[1]),
    luamp.arrow(
        levels[3][1].tail_bullet,
        levels[3][2]),
    luamp.arrow(
        levels[3][2].tail_bullet,
        levels[3][3]),
    luamp.arrow(
        levels[3][3].tail_bullet,
        levels[3][4]),
    luamp.arrow(
        levels[3][4].tail_bullet,
        levels[3][5])})
    :collect(figs)

local ps = stream.from_list(levels[3])
    :map(function(x)
        return stream.from_list(x.ptr_bullets)
            :take(#x.texts)
    end)
    :flatten()
    :collect()
local rs = stream.from_list(ps)
    :map(function(x)
        return luamp.rectangle(
            x:center() + luamp.point(0, -1),
            0.5,
            0.5)
    end)
    :collect()
stream
    .zip(
        stream.from_list(ps),
        stream.from_list(rs))
    :map(function(x)
        local bullet = x[1]
        local rect = x[2]
        return luamp.arrow(bullet, rect)
    end)
    :collect(figs)
local vs = {
    '$v_0$',
    '$v_1$',
    '$v_2$',
    '$v_4$',
    '$v_5$',
    '$v_6$',
    '$v_7$',
    '$v_8$'}
stream
    .zip(
        stream.from_list(rs),
        stream.from_list(vs))
    :map(function(x)
        local rect = x[1]
        local text = x[2]
        return luamp.text(
            rect:center(),
            luamp.directions.center,
            text)
    end)
    :collect(figs)

print(luamp.figure(table.unpack(figs)))

