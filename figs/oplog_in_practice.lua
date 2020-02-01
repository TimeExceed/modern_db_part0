package.path = package.path .. ';lib/?.lua'
local luamp = require 'luamp'
local stream = require 'stream'
local table = require 'table'
local string = require 'string'

local SEG_WIDTH = 1
local SEG_HEIGHT = 0.6
local HEADER_WIDTH = 1.2
local FOOTER_WIDTH = 1.2

local matrix = luamp.layouts.matrix(luamp.origin, 0.8, 1,
    {{false, false},
     {false, false},
     {false, false}})

local figs = {}

stream.from_list({
    luamp.text(
        matrix[1][1],
        luamp.directions.center,
        '$\\text{epoch}_0$'),
    luamp.text(
        matrix[3][1],
        luamp.directions.center,
        '$\\text{epoch}_m$'),
    luamp.text(
        matrix[2][2],
        luamp.directions.right,
        '\\dots')})
    :flatten()
    :collect(figs)

local function epoch0()
    local texts = {'op', '\\dots', 'idx', 'op', '\\dots', 'idx'}
    local entire_width = HEADER_WIDTH + FOOTER_WIDTH + SEG_WIDTH * #texts
    local entire_height = SEG_HEIGHT
    local leftmost = matrix[1][2]
    local rightmost = leftmost + luamp.point(entire_width, 0)

    stream.from_list({
        stream.iterate(
            leftmost + luamp.point(HEADER_WIDTH, 0),
            function(x)
                return x + luamp.point(SEG_WIDTH, 0)
            end)
            :map(function(x)
                return luamp.line(
                    x + luamp.point(0, SEG_HEIGHT/2),
                    x + luamp.point(0, -SEG_HEIGHT/2))
            end)
            :take(#texts + 1),
        stream.zip(
            stream.from_list(texts),
            stream.iterate(
                leftmost + luamp.point(HEADER_WIDTH + SEG_WIDTH/2, 0),
                function(x)
                    return x + luamp.point(SEG_WIDTH, 0)
                end))
            :map(function(x)
                local text = x[1]
                local center = x[2]
                return luamp.text(center, luamp.directions.center, text)
            end),
        luamp.text(
            leftmost + luamp.point(HEADER_WIDTH/2, 0),
            luamp.directions.center,
            'header'),
        luamp.text(
            rightmost + luamp.point(-FOOTER_WIDTH/2, 0),
            luamp.directions.center,
            'footer'),
        luamp.rectangle(luamp.centroid(leftmost, rightmost), entire_width, entire_height)})
        :flatten()
        :collect(figs)
end
epoch0()

local function epoch_m()
    local entire_width = HEADER_WIDTH + 2 * SEG_WIDTH
    local entire_height = SEG_HEIGHT
    local leftmost = matrix[3][2]
    local rightmost = leftmost + luamp.point(entire_width, 0)

    stream.from_list({
        stream.iterate(
            leftmost + luamp.point(HEADER_WIDTH, 0),
            function(x)
                return x + luamp.point(SEG_WIDTH, 0)
            end)
            :map(function(x)
                return luamp.line(
                    x + luamp.point(0, SEG_HEIGHT/2),
                    x + luamp.point(0, -SEG_HEIGHT/2))
            end)
            :take(3),
        stream.zip(
            stream.from_list({'$\\text{op}_{m,0}$', '\\dots'}),
            stream.iterate(
                leftmost + luamp.point(HEADER_WIDTH + SEG_WIDTH/2, 0),
                function(x)
                    return x + luamp.point(SEG_WIDTH, 0)
                end))
            :map(function(x)
                local text = x[1]
                local center = x[2]
                return luamp.text(center, luamp.directions.center, text)
            end),
        luamp.text(
            leftmost + luamp.point(HEADER_WIDTH/2, 0),
            luamp.directions.center,
            'header'),
        luamp.arrow(
            rightmost + luamp.point(SEG_WIDTH * 3 / 2, 0) + luamp.point(-0.3, 0),
            rightmost + luamp.point(SEG_WIDTH/2, 0)),
        luamp.text(
            rightmost + luamp.point(SEG_WIDTH * 3 / 2, 0) + luamp.point(0.2, 0),
            luamp.directions.center,
            '$\\text{op}_{m,i}$'),
        luamp.rectangle(luamp.centroid(leftmost, rightmost), entire_width, entire_height)})
        :flatten()
        :collect(figs)

    local vs = {
        luamp.point(0, SEG_HEIGHT/2),
        luamp.point(SEG_WIDTH, SEG_HEIGHT/2),
        luamp.point(SEG_WIDTH, -SEG_HEIGHT/2),
        luamp.point(0, -SEG_HEIGHT/2)}
    local vs = stream.from_list(vs)
        :map(function(x)
            return rightmost + x
        end)
        :collect()
    stream
        .zip(
            stream.from_list(vs),
            stream.from_list(vs)
                :drop(1))
        :map(function(x)
            return luamp.line(x[1], x[2], {line_style=luamp.line_styles.dashed})
        end)
        :collect(figs)
end
epoch_m()

print(luamp.figure(table.unpack(figs)))
