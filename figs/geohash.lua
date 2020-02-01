package.path = package.path .. ';lib/?.lua'
local luamp = require 'luamp'
local stream = require 'stream'
local table = require 'table'

local tree = luamp.layouts.tree(
    luamp.origin,
    1.3, 2,
    {false,
        {false,
            {false}},
        {false,
            {false}}})

local function upside_down(p)
    return luamp.point(p.x, -p.y)
end
local root = upside_down(tree[1])
local left = upside_down(tree[2][1])
local right = upside_down(tree[3][1])
local left_up = upside_down(tree[2][2][1])
local right_up = upside_down(tree[3][2][1])

local figs = {}

local function fraction(center, value)
    local SEG_NUM = 3
    local SEG_W = 0.2
    local SEG_H = 0.4

    local texts = stream
        .iterate(
            0.5,
            function(x)
                return x/2
            end)
        :map(function(x)
            if value > x then
                value = value - x
                return 1
            else
                return 0
            end
        end)
        :map(function(x)
            return string.format('%d', x)
        end)
        :take(SEG_NUM)
        :collect()
    local segs = stream
        .iterate(
            center + luamp.point(-SEG_W * (SEG_NUM - 1) / 2, 0),
            function(x)
                return x + luamp.point(SEG_W, 0)
            end)
        :map(function(x)
            return luamp.rectangle(x, SEG_W, SEG_H)
        end)
        :take(SEG_NUM)
        :collect()
    stream.from_list(segs):collect(figs)
    table.insert(
        figs,
        luamp.text(
            luamp.centroid(segs[1]:vertices()[1], segs[1]:vertices()[4]),
            luamp.directions.left,
            '0.'))
    local segs = stream
        .zip(
            stream.from_list(segs),
            stream.from_list(texts))
        :collect()
    stream.from_list(segs)
        :map(function(x)
            return luamp.text(x[1]:center(), luamp.directions.center, x[2])
        end)
        :collect(figs)
    return segs
end

table.insert(figs, luamp.text(left_up, luamp.directions.center, '$121^\\circ$E'))
local left_up = luamp.rectangle(left_up, 1, 0.4)
local left = fraction(left, (180+121)/360)
table.insert(figs, luamp.arrow(left_up, left[2][1]))

table.insert(figs, luamp.text(right_up, luamp.directions.center, '$31^\\circ$N'))
local right_up = luamp.rectangle(right_up, 1, 0.4)
local right = fraction(right, (31+90)/90)
table.insert(figs, luamp.arrow(right_up, right[2][1]))

local function draw_root(root, left, right)
    local SEG_W = 0.2
    local SEG_H = 0.4
    local n = #left + #right
    local segs = stream
        .iterate(
            root + luamp.point(-SEG_W * (n - 1) / 2, 0),
            function(x)
                return x + luamp.point(SEG_W, 0)
            end)
        :map(function(x)
            return luamp.rectangle(x, SEG_W, SEG_H)
        end)
        :take(n)
        :collect()
    stream.from_list(segs):collect(figs)

    local function draw_seg(seg, src, text)
        table.insert(figs, luamp.text(seg:center(), luamp.directions.center, text))
        table.insert(
            figs,
            luamp.arrow(
                luamp.centroid(src:vertices()[3], src:vertices()[4]),
                luamp.centroid(seg:vertices()[1], seg:vertices()[2])))
    end

    for i = 1, #left do
        local seg = segs[i * 2 - 1]
        local src = left[i][1]
        local text = left[i][2]
        draw_seg(seg, src, text)
    end
    for i = 1, #right do
        local seg = segs[i * 2]
        local src = right[i][1]
        local text = right[i][2]
        draw_seg(seg, src, text)
    end
end
draw_root(root, left, right)

print(luamp.figure(table.unpack(figs)))
