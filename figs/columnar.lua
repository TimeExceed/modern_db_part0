package.path = package.path .. ';lib/?.lua'
local luamp = require 'luamp'
local stream = require 'stream'
local table = require 'table'

local figs = {}

local function file_format()
    local SEG_HEIGHT = 0.8
    local SEG_WIDTH = 2
    local TEXTS = {'File Header', 'Seg Header', 'Column Data', 'Column Index', 'Seg Footer', '\\dots', 'File Footer'}

    local segs = stream
        .zip(
            stream.from_list(TEXTS),
            stream
                .iterate(
                    luamp.origin,
                    function(x)
                        return x + luamp.point(0, -SEG_HEIGHT)
                    end))
        :map(function(x)
            local text = x[1]
            local center = x[2]
            if string.find(text, 'File') ~= nil then
                return luamp.rectangle(
                    center, SEG_WIDTH, SEG_HEIGHT,
                    {brush_color=luamp.colors.purple})
            else
                return luamp.rectangle(
                    center, SEG_WIDTH, SEG_HEIGHT,
                    {brush_color=luamp.colors.orange})
            end
        end)
        :collect()
    stream.from_list(segs)
        :collect(figs)
    stream
        .zip(
            stream.from_list(segs),
            stream.from_list(TEXTS))
        :map(function(x)
            return luamp.text(x[1]:center(), luamp.directions.center, x[2])
        end)
        :collect(figs)
    return segs
end
local segs = file_format()
local column_index_seg = segs[4]
local column_data_seg = segs[3]

local function index_tree()
    local tree = luamp.layouts.tree(
        luamp.point(3.5, -1.7),
        1, 1,
        {false, {luamp.bullet}, {luamp.bullet}})
    local root = tree[1]
    local left = tree[2][1]
    local right = tree[3][1]
    table.insert(figs, left)
    table.insert(figs, right)
    local left_edge = luamp.line(root, left)
    table.insert(figs, left_edge)
    table.insert(
        figs,
        luamp.text(
            luamp.centroid(table.unpack(left_edge:vertices())),
            luamp.directions.top_left,
            'age'))
    local right_edge = luamp.line(root, right)
    table.insert(figs, right_edge)
    table.insert(
        figs,
        luamp.text(
            luamp.centroid(table.unpack(right_edge:vertices())),
            luamp.directions.top_right,
            'name'))

    return root, left, right
end
local root, left, right = index_tree()
local bbox = luamp.rectangle(luamp.centroid(root, root, left:center(), right:center()), 1.5, 1)
table.insert(
    figs,
    luamp.arrow(
        luamp.centroid(column_index_seg:vertices()[2], column_index_seg:vertices()[3]),
        luamp.centroid(bbox:vertices()[1], bbox:vertices()[4]),
        {line_style=luamp.line_styles.dashed}))

local function column_data(leftmost, texts)
    local CELL_WIDTH = 0.8
    local CELL_HEIGHT = 0.5

    local ps = stream
        .iterate(
            leftmost + luamp.point(CELL_WIDTH/2, 0),
            function(x)
                return x + luamp.point(CELL_WIDTH, 0)
            end)
        :take(#texts)
        :collect()
    stream
        .zip(
            stream.from_list(ps),
            stream.from_list(texts))
        :map(function(x)
            return luamp.text(x[1], luamp.directions.center, x[2])
        end)
        :collect(figs)
    table.insert(
        figs,
        luamp.rectangle(
            luamp.centroid(ps[1], ps[#ps]),
            CELL_WIDTH * #ps,
            CELL_HEIGHT))
end
local age_cell = luamp.point(5, -3)
column_data(age_cell, {'18', '20', '21', '21', '18'})
local name_cell = luamp.point(5, -3.5)
column_data(name_cell, {'Alice', 'Alice', 'Alice', 'Alan', 'Alan'})
table.insert(
    figs,
    luamp.arrow(
        luamp.centroid(column_data_seg:vertices()[2], column_data_seg:vertices()[3]),
        luamp.centroid(age_cell, name_cell) + luamp.point(-0.3, 0),
        {line_style=luamp.line_styles.dashed}))

table.insert(
    figs,
    luamp.arrow(left, age_cell))
table.insert(
    figs,
    luamp.arrow(right, name_cell))

print(luamp.figure(table.unpack(figs)))
