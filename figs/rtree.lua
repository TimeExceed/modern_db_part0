package.path = package.path .. ';lib/?.lua'
local luamp = require 'luamp'
local stream = require 'stream'
local table = require 'table'

local tree = luamp.layouts.tree(
    luamp.origin,
    1, 1.2,
    {false,
        {false,
            {false},
            {false}},
        {false,
            {false},
            {false}}})

local root = tree[1]
local left = tree[2]
local right = tree[3]
local left_left = left[2]
local left_right = left[3]
local right_left = right[2]
local right_right = right[3]
left = left[1]
right = right[1]
left_left = left_left[1]
left_right = left_right[1]
right_left = right_left[1]
right_right = right_right[1]

local figs = {}

local function node(center, opts)
    local SEG_WIDTH = 0.5
    local SEG_HEIGHT = 0.4
    table.insert(
        figs,
        luamp.rectangle(center, SEG_WIDTH*2, SEG_HEIGHT, opts))
    table.insert(
        figs,
        luamp.line(
            center + luamp.point(0, SEG_HEIGHT/2),
            center + luamp.point(0, -SEG_HEIGHT/2),
            opts))
    return stream
        .iterate(
            center + luamp.point(-SEG_WIDTH/2, 0),
            function(x)
                return x + luamp.point(SEG_WIDTH, 0)
            end)
        :map(function(x)
            return luamp.rectangle(x, SEG_WIDTH, SEG_HEIGHT)
        end)
        :take(2)
        :collect()
end

local function tree_edge(root_node, left_node, right_node)
    local function draw_edge(seg1, seg2)
        table.insert(
            figs,
            luamp.arrow(
                luamp.centroid(seg1:vertices()[3], seg1:vertices()[4]),
                luamp.centroid(seg2:vertices()[1], seg2:vertices()[2])))
    end
    draw_edge(root_node[1], left_node[1])
    draw_edge(root_node[2], right_node[1])
end

local segs_root = node(root)
local segs_left = node(left, {pen_color=luamp.colors.red})
local segs_right = node(right, {pen_color=luamp.colors.red})
local segs_left_left = node(left_left, {pen_color=luamp.colors.blue})
local segs_left_right = node(left_right, {pen_color=luamp.colors.blue})
local segs_right_left = node(right_left, {pen_color=luamp.colors.blue})
local segs_right_right = node(right_right, {pen_color=luamp.colors.blue})

tree_edge(segs_root, segs_left, segs_right)
tree_edge(segs_left, segs_left_left, segs_left_right)
tree_edge(segs_right, segs_right_left, segs_right_right)

table.insert(figs, luamp.text(segs_left_left[1]:center(), luamp.directions.center, '$a$'))
table.insert(figs, luamp.text(segs_left_left[2]:center(), luamp.directions.center, '$b$'))
table.insert(figs, luamp.text(segs_left_right[1]:center(), luamp.directions.center, '$c$'))
table.insert(figs, luamp.text(segs_left_right[2]:center(), luamp.directions.center, '$d$'))
table.insert(figs, luamp.text(segs_right_left[1]:center(), luamp.directions.center, '$e$'))
table.insert(figs, luamp.text(segs_right_left[2]:center(), luamp.directions.center, '$f$'))
table.insert(figs, luamp.text(segs_right_right[1]:center(), luamp.directions.center, '$g$'))
table.insert(figs, luamp.text(segs_right_right[2]:center(), luamp.directions.center, '$h$'))

print(luamp.figure(table.unpack(figs)))
