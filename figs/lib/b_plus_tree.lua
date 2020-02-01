local luamp = require 'luamp'
local stream = require 'stream'
local string = require 'string'
local table = require 'table'
local io = require 'io'

local BRANCH = 3

local Inner = luamp.ext.clone_table(luamp.ext.Base)

Inner.SEG_WIDTH = 0.5
Inner.LEFTMOST_WIDTH = 0.3
Inner.KEY_HEIGHT = 0.5
Inner.PTR_HEIGHT = 0.3

function Inner.__tostring(this)
    return string.format('(Inner center=%s)', this.m_center)
end

function Inner.vertices(this)
    return luamp.rectangle(this.m_center, this.m_width, this.m_height)
        :vertices()
end

function Inner._draw_bbox_(this, figs)
    local bb = luamp.rectangle(
        this.m_center,
        this.m_width,
        this.m_height,
        rawget(this, 'm_opts'))
    table.insert(figs, bb)
end

function Inner._draw_lines_(this, figs)
    local upleft_corner = this:vertices()[1]
    stream.iterate(
        upleft_corner + luamp.point(Inner.LEFTMOST_WIDTH, 0),
        function(x)
            return x + luamp.point(Inner.SEG_WIDTH, 0)
        end)
        :take(BRANCH - 1)
        :map(function(x)
            return luamp.line(
                x,
                x + luamp.point(0, -this.m_height),
                rawget(this, 'm_opts'))
        end)
        :collect(figs)
    local hor = luamp.line(
        upleft_corner + luamp.point(0, -Inner.KEY_HEIGHT),
        upleft_corner + luamp.point(this.m_width, -Inner.KEY_HEIGHT),
        rawget(this, 'm_opts'))
    table.insert(figs, hor)
end

function Inner._draw_texts_(this, figs)
    local upleft_corner = this:vertices()[1]
    local offset = luamp.point(
        Inner.LEFTMOST_WIDTH + Inner.SEG_WIDTH / 2,
        -Inner.KEY_HEIGHT/2)
    local cs = stream.iterate(
        upleft_corner + offset,
        function(last)
            return last + luamp.point(Inner.SEG_WIDTH, 0)
        end)
    local ts = stream.from_list(this.m_texts)
    stream.zip(cs, ts)
        :map(function(x)
            local c = x[1]
            local t = x[2]
            return luamp.text(c, luamp.directions.center, t)
        end)
        :collect(figs)
end

function Inner._draw_ptr_bullets_(this, figs)
    stream.from_list(this.ptr_bullets)
        :take(#this.m_texts + 1)
        :collect(figs)
end

function Inner._draw_gray_upleft_rect_(this, figs)
    local upleft_corner = this:vertices()[1]
    local c = upleft_corner + luamp.point(Inner.LEFTMOST_WIDTH/2, -Inner.KEY_HEIGHT/2)
    local rect = luamp.rectangle(
        c,
        Inner.LEFTMOST_WIDTH,
        Inner.KEY_HEIGHT,
        {brush_color=luamp.colors.gray, pen_color=luamp.colors.invisible})
    table.insert(figs, rect)
end

function Inner._draw(this, outs)
    local figs = {}
    Inner._draw_bbox_(this, figs)
    Inner._draw_lines_(this, figs)
    Inner._draw_texts_(this, figs)
    Inner._draw_ptr_bullets_(this, figs)
    Inner._draw_gray_upleft_rect_(this, figs)

    stream.from_list(figs)
        :map(function(x)
            x:_draw(outs)
            return true
        end)
        :collect()
end

function Inner._intersect_line(this, target)
    local rect = luamp.rectangle(this.m_center, this.m_width, this.m_height)
    return rect:_intersect_line(target)
end

function Inner._ptr_bullets_(this)
    local vertices = Inner.vertices(this)
    local bot_left = vertices[#vertices]
    local offset0 = luamp.point(Inner.LEFTMOST_WIDTH/2, Inner.PTR_HEIGHT/2)
    local offset1 = luamp.point(Inner.LEFTMOST_WIDTH+Inner.SEG_WIDTH/2, Inner.PTR_HEIGHT/2)
    local xs = stream.from_list({
        bot_left + offset0,
        stream.iterate(
            bot_left + offset1,
            function(x)
                return x + luamp.point(Inner.SEG_WIDTH, 0)
            end
        )
    })
    return xs
        :flatten()
        :take(BRANCH)
        :map(function(x)
            return luamp.bullet(x)
        end)
        :collect()
end

function Inner.new(center, texts, opts)
    assert(#texts < BRANCH, #texts)
    local width = (BRANCH - 1) * Inner.SEG_WIDTH + Inner.LEFTMOST_WIDTH
    local height = Inner.KEY_HEIGHT + Inner.PTR_HEIGHT
    local res = {
        m_center = center,
        m_texts = texts,
        m_opts = opts,
        m_width = width,
        m_height = height,
    }
    res.ptr_bullets = Inner._ptr_bullets_(res)

    return setmetatable(res, Inner)
end

local Leaf = luamp.ext.clone_table(luamp.ext.Base)

Leaf.RIGHTMOST_WIDTH = 0.3
Leaf.SEG_WIDTH = 0.5
Leaf.KEY_HEIGHT = 0.5
Leaf.PTR_HEIGHT = 0.3

function Leaf.__tostring(this)
    return string.format('(Leaf center=%s)', this.m_center)
end

function Leaf.vertices(this)
    local half_width = this.m_width / 2
    local half_height = this.m_height / 2

    return {
        luamp.point(this.m_center.x - half_width, this.m_center.y + half_height),
        luamp.point(this.m_center.x + half_width, this.m_center.y + half_height),
        luamp.point(this.m_center.x + half_width, this.m_center.y - half_height),
        luamp.point(this.m_center.x - half_width, this.m_center.y - half_height),
    }
end

function Leaf._intersect_line(this, target)
    local rect = luamp.rectangle(this.m_center, this.m_width, this.m_height)
    return rect:_intersect_line(target)
end

function Leaf._tail_bullet(this)
    local vertices = Leaf.vertices(this)
    local upright_corner = vertices[2]
    local botright_corner = vertices[3]
    local rec_upright = upright_corner + luamp.point(-Leaf.RIGHTMOST_WIDTH, 0)
    local c = luamp.centroid(rec_upright, botright_corner)
    return luamp.bullet(c)
end

function Leaf._ptr_bullets(this)
    local vertices = Leaf.vertices(this)
    local botleft = vertices[#vertices]
    return stream
        .iterate(
            botleft + luamp.point(Leaf.SEG_WIDTH/2, Leaf.PTR_HEIGHT/2),
            function(x)
                return x + luamp.point(Leaf.SEG_WIDTH, 0)
            end)
        :map(function(x)
            return luamp.bullet(x)
        end)
        :take(BRANCH - 1)
        :collect()
end

function Leaf._key_rects(this)
    local vertices = Leaf.vertices(this)
    local upleft = vertices[1]
    return stream
        .iterate(
            upleft + luamp.point(Leaf.SEG_WIDTH/2, -Leaf.KEY_HEIGHT/2),
            function(x)
                return x + luamp.point(Leaf.SEG_WIDTH, 0)
            end)
        :map(function(x)
            return luamp.rectangle(x, Leaf.SEG_WIDTH, Leaf.KEY_HEIGHT)
        end)
        :take(BRANCH - 1)
        :collect()
end

function Leaf.new(center, texts, opts)
    assert(#texts < BRANCH, #texts)
    local width = (BRANCH - 1) * Leaf.SEG_WIDTH + Leaf.RIGHTMOST_WIDTH
    local height = Leaf.KEY_HEIGHT + Leaf.PTR_HEIGHT
    local res = {
        m_center = center,
        m_texts = texts,
        m_width = width,
        m_height = height,
        m_opts = opts,
    }
    res.tail_bullet = Leaf._tail_bullet(res)
    res.ptr_bullets = Leaf._ptr_bullets(res)
    res.key_rects = Leaf._key_rects(res)
    return setmetatable(res, Leaf)
end

function Leaf._draw_bbox_(this, figs)
    local bb = luamp.rectangle(this.m_center, this.m_width, this.m_height, rawget(this, 'm_opts'))
    table.insert(figs, bb)
end

function Leaf._draw_lines_(this, figs)
    local upleft_corner = this:vertices()[1]
    stream.iterate(
        upleft_corner + luamp.point(Leaf.SEG_WIDTH, 0),
        function(x)
            return x + luamp.point(Leaf.SEG_WIDTH, 0)
        end)
        :take(BRANCH - 1)
        :map(function(x)
            return luamp.line(x, x + luamp.point(0, -this.m_height), rawget(this, 'm_opts'))
        end)
        :collect(figs)
    local hor = luamp.line(
        upleft_corner + luamp.point(0, -Leaf.KEY_HEIGHT),
        upleft_corner + luamp.point(this.m_width - Leaf.RIGHTMOST_WIDTH, -Leaf.KEY_HEIGHT),
        rawget(this, 'm_opts'))
    table.insert(figs, hor)
end

function Leaf._draw_texts_(this, figs)
    local upleft_corner = this:vertices()[1]
    local offset = luamp.point(Leaf.SEG_WIDTH / 2, -Leaf.KEY_HEIGHT/2)
    local c = upleft_corner + offset
    local cs = stream.iterate(c, function(last)
        return last + luamp.point(Leaf.SEG_WIDTH, 0)
    end)
    local ts = stream.from_list(this.m_texts)
    stream.zip(cs, ts)
        :map(function(x)
            local c = x[1]
            local t = x[2]
            return luamp.text(c, luamp.directions.center, t)
        end)
        :collect(figs)
end

function Leaf._draw_ptr_bullets_(this, figs)
    stream.from_list(this.ptr_bullets)
        :take(#this.m_texts)
        :collect(figs)
end

function Leaf._draw_tail_bullet_(this, figs)
    table.insert(figs, this.tail_bullet)
end

function Leaf._draw(this, outs)
    local figs = {}
    Leaf._draw_bbox_(this, figs)
    Leaf._draw_lines_(this, figs)
    Leaf._draw_texts_(this, figs)
    Leaf._draw_ptr_bullets_(this, figs)
    Leaf._draw_tail_bullet_(this, figs)

    stream.from_list(figs)
        :map(function(x)
            x:_draw(outs)
            return true
        end)
        :collect()
end

local tree = luamp.layouts.tree(
    luamp.origin,
    2,
    2,
    {false,
        {false,
            {false},
            {false},
            {false}},
        {false,
            {false},
            {false}}}
)

local levels = {}
local function levelled_collect(trees)
    local this_level_nodes = stream.from_list(trees)
        :map(function(x)
            return x[1]
        end)
        :collect()
    table.insert(levels, this_level_nodes)

    local next_level_trees = stream.from_list(trees)
        :map(function(x)
            return stream.from_list(x):drop(1)
        end)
        :flatten()
        :collect()
    if #next_level_trees > 0 then
        levelled_collect(next_level_trees)
    end
end
levelled_collect({tree})

levels[1][1] = Inner.new(levels[1][1], {'5'})
levels[2][1] = Inner.new(levels[2][1], {'2', '4'})
levels[2][2] = Inner.new(levels[2][2], {'7'})
levels[3][1] = Leaf.new(levels[3][1], {'0', '1'})
levels[3][2] = Leaf.new(levels[3][2], {'2'})
levels[3][3] = Leaf.new(levels[3][3], {'4'})
levels[3][4] = Leaf.new(levels[3][4], {'5', '6'})
levels[3][5] = Leaf.new(levels[3][5], {'7', '8'})

return {
    Inner = Inner,
    Leaf = Leaf,
    levels = levels,
}