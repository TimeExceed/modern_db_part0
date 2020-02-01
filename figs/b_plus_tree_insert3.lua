package.path = package.path .. ';lib/?.lua'
local table = require 'table'
local luamp = require 'luamp'
local stream = require 'stream'
local btree = require 'b_plus_tree'

local figs = {}
local levels = btree.levels
levels[1][1] = btree.Inner.new(levels[1][1]:center(), {'5'}, {pen_color=luamp.colors.blue})
levels[2][1] = btree.Inner.new(levels[2][1]:center(), {'2', '4'}, {pen_color=luamp.colors.blue})
levels[3][2] = btree.Leaf.new(levels[3][2]:center(), {'2', ''}, {pen_color=luamp.colors.red})

stream.from_list(levels)
    :map(function(x)
        return stream.from_list(x)
    end)
    :flatten()
    :collect(figs)

stream.from_list({
    luamp.arrow(
        levels[1][1].ptr_bullets[1],
        levels[2][1]:vertices()[1],
        {pen_color=luamp.colors.blue}),
    luamp.arrow(
        levels[1][1].ptr_bullets[2],
        levels[2][2]:vertices()[1]),
    luamp.arrow(
        levels[2][1].ptr_bullets[1],
        levels[3][1]:vertices()[1]),
    luamp.arrow(
        levels[2][1].ptr_bullets[2],
        levels[3][2]:vertices()[1],
        {pen_color=luamp.colors.blue}),
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
local vs = {
    '$v_0$',
    '$v_1$',
    '$v_2$',
    '$v_3$',
    '$v_4$',
    '$v_5$',
    '$v_6$',
    '$v_7$',
    '$v_8$'}
stream
    .zip(
        stream.iterate(0, function(x)
            return x + 1
        end),
        stream.from_list(ps),
        stream.from_list(rs),
        stream.from_list(vs))
    :map(function(x)
        local idx = x[1]
        local bullet = x[2]
        local rect = x[3]
        local text = x[4]
        if idx == 3 then
            return stream.from_list({
                luamp.arrow(bullet, rect, {pen_color=luamp.colors.red}),
                luamp.text(
                    rect:center(),
                    luamp.directions.center,
                    text,
                    {pen_color=luamp.colors.red})
            })
        else
            return stream.from_list({
                luamp.arrow(bullet, rect),
                luamp.text(
                    rect:center(),
                    luamp.directions.center,
                    text)
            })
        end
    end)
    :flatten()
    :collect(figs)

table.insert(
    figs,
    luamp.text(levels[3][2].key_rects[2]:center(), luamp.directions.center, '3', {pen_color=luamp.colors.red}))

print(luamp.figure(table.unpack(figs)))


