package.path = package.path .. ';lib/?.lua'
local luamp = require 'luamp'
local stream = require 'stream'
local table = require 'table'

local seps_y = {1, 3, 5}

local figs = {}

stream.from_list(seps_y)
    :map(function(y)
        return luamp.line(
            luamp.point(0, y),
            luamp.point(10, y),
            {line_style=luamp.line_styles.dashed})
    end)
    :collect(figs)
stream.from_list(seps_y)
    :take(2)
    :map(function(y)
        return stream.from_list({
            luamp.arrow(
                luamp.point(5, y) + luamp.point(0, 0.3),
                luamp.point(5, y) + luamp.point(0, -0.3)),
            luamp.text(
                luamp.point(5, y),
                luamp.directions.top_right,
                'compact')})
    end)
    :flatten()
    :collect(figs)

local function level2()
    stream.from_list({
        luamp.text(luamp.origin, luamp.directions.right, '$L_2$'),
        luamp.triangle(luamp.point(5, 0), 4, 0.8)})
        :collect(figs)
end
level2()

local function level1()
    local center_y = (seps_y[1] + seps_y[2]) / 2
    stream.from_list({
        luamp.text(luamp.point(0, center_y), luamp.directions.right, '$L_1$'),
        })
        :collect(figs)
    local xs = {2, 5, 8}
    stream.from_list(xs)
        :map(function(x)
            return luamp.triangle(luamp.point(x, center_y), 2, 0.8)
        end)
        :collect(figs)
    stream.zip(
        stream.from_list(xs),
        stream.from_list(xs):drop(1))
        :map(function(v)
            local x = (v[1] + v[2]) / 2
            return luamp.line(
                luamp.point(x, center_y) + luamp.point(0, 0.7),
                luamp.point(x, center_y) + luamp.point(0, -0.6),
                {line_style=luamp.line_styles.dashed})
        end)
        :collect(figs)
end
level1()

local function level0()
    local center_y = (seps_y[2] + seps_y[3]) / 2
    stream.from_list({
        luamp.text(luamp.point(0, center_y), luamp.directions.right, '$L_0$'),
        luamp.triangle(
            luamp.point(4.9, -0.3) + luamp.point(0, center_y),
            0.4,
            0.1),
        luamp.triangle(
            luamp.point(6.8, -0.0) + luamp.point(0, center_y),
            0.9,
            0.3),
        luamp.triangle(
            luamp.point(3.8, 0.57) + luamp.point(0, center_y),
            1.2,
            0.15),
        luamp.triangle(
            luamp.point(1.64, -0.09) + luamp.point(0, center_y),
            0.48,
            0.31),
        luamp.triangle(
            luamp.point(4.84, 0.01) + luamp.point(0, center_y),
            0.64,
            0.15),
        luamp.triangle(
            luamp.point(8.60, 0.26) + luamp.point(0, center_y),
            1.37,
            0.34),
        luamp.triangle(
            luamp.point(8.07, -0.29) + luamp.point(0, center_y),
            1.28,
            0.46)})
        :collect(figs)
end
level0()

local function mem()
    local y = seps_y[3] + 0.7

    local active = luamp.triangle(luamp.point(4.5, y), 1, 0.4)
    table.insert(figs, active)
    local active_vertices = active:vertices()
    local active_text = luamp.text(
        luamp.centroid(active_vertices[1], active_vertices[3]),
        luamp.directions.bottom,
        '\\scriptsize active memtable')
    table.insert(figs, active_text)

    local rect_width = 0.4
    local rect_height = 0.4
    local oplog = luamp.rectangle(luamp.point(2, y), rect_width * 4, rect_height)
    table.insert(figs, oplog)
    table.insert(figs, luamp.arrow(oplog, active, {pen_color=luamp.colors.blue}))
    stream.iterate(
        oplog:vertices()[1],
        function(x)
            return x + luamp.point(rect_width, 0)
        end)
        :drop(1)
        :take(3)
        :map(function(x)
            return luamp.line(x, x + luamp.point(0, -rect_height))
        end)
        :collect(figs)
    table.insert(
        figs,
        luamp.text(
            oplog:center() + luamp.point(0, -rect_height/2),
            luamp.directions.bottom,
            '\\scriptsize oplog'))
    local rightmost_oplog = luamp.rectangle(
        oplog:vertices()[2] + luamp.point(-rect_width/2, -rect_height/2),
        rect_width,
        rect_height)

    local write = luamp.text(
        rightmost_oplog:center() + luamp.point(0, 0.5),
        luamp.directions.top,
        '\\scriptsize write',
        {pen_color=luamp.colors.blue})
    table.insert(figs, write)

    local shadow = luamp.triangle(luamp.point(7, y), 1, 0.4)
    table.insert(figs, shadow)
    local shadow_vertices = shadow:vertices()
    local shadow_text = luamp.text(
        luamp.centroid(shadow_vertices[1], shadow_vertices[3]),
        luamp.directions.bottom,
        '\\scriptsize shadowed memtable')
    table.insert(figs, shadow_text)

    stream.from_list({
        luamp.arrow(
            write:center(),
            rightmost_oplog,
            {pen_color=luamp.colors.blue}),
        luamp.arrow(
            active,
            shadow,
            {pen_color=luamp.colors.blue, line_style=luamp.line_styles.dashed}),
        luamp.arrow(
            shadow,
            luamp.point(7, 4.5),
            {pen_color=luamp.colors.blue, line_style=luamp.line_styles.dashed}),
        luamp.text(
            luamp.point(7, 5),
            luamp.directions.bottom_right,
            'dump')})
        :collect(figs)
end
mem()

print(luamp.figure(table.unpack(figs)))
