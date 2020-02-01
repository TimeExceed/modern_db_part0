package.path = package.path .. ';lib/?.lua'
local luamp = require 'luamp'
local stream = require 'stream'
local table = require 'table'
local skiplist = require 'skiplist_lib'

local draw_doc_chain = skiplist.draw_doc_chain

local tree = luamp.layouts.tree(
    luamp.origin,
    1,
    2,
    {false,
        {luamp.bullet,
            {luamp.bullet,
                {luamp.bullet,
                    {luamp.bullet}},
                {luamp.bullet,
                    {luamp.bullet,
                        {luamp.bullet}}}}}})

local a = tree[2]
local al = a[2]
local ala = al[2]
local alan = ala[2]
local ali = al[3]
local alic = ali[2]
local alice = alic[2]

local rt = tree[1]
a = luamp.bullet(a[1]:center())
al = luamp.bullet(al[1]:center())
ala = luamp.bullet(ala[1]:center())
alan = luamp.bullet(alan[1]:center(), {brush_color=luamp.colors.red})
ali = luamp.bullet(ali[1]:center())
alic = luamp.bullet(alic[1]:center())
alice = luamp.bullet(alice[1]:center(), {brush_color=luamp.colors.red})

local figs = {}

local function draw_tree(t)
    local r = t[1]
    table.insert(figs, r)
    for i = 2, #t do
        table.insert(figs, luamp.line(r, t[i][1]))
        draw_tree(t[i])
    end
end
-- draw_tree(tree)

stream.from_list({a, al, ala, alan, ali, alic, alice})
    :collect(figs)

local function draw_chain(vs, ts)
    stream
        .zip(
            stream.from_list(vs),
            stream.from_list(vs):drop(1),
            stream.from_list(ts))
        :map(function(x)
            local l = luamp.line(x[1], x[2])
            return stream.from_list({l, x[3](l:center())})
        end)
        :flatten()
        :collect(figs)
end
local vs = {rt, a, al, ala, alan}
local ts = {
    function(x) return luamp.text(x, luamp.directions.left, 'a') end,
    function(x) return luamp.text(x, luamp.directions.left, 'l') end,
    function(x) return luamp.text(x, luamp.directions.top_left, 'a') end,
    function(x) return luamp.text(x, luamp.directions.left, 'n') end,
}
draw_chain(vs, ts)
local vs = {al, ali, alic, alice}
local ts = {
    function(x) return luamp.text(x, luamp.directions.left, 'i') end,
    function(x) return luamp.text(x, luamp.directions.left, 'c') end,
    function(x) return luamp.text(x, luamp.directions.left, 'e') end,
}
draw_chain(vs, ts)

local ALICE_START_POINT = luamp.point(3, -1)

local c0 = luamp.circle(luamp.point(3, 0), 0.2)
local c1 = luamp.circle(luamp.point(4, 0), 0.2)
luamp.line(c0, c1)

local alice_docs = draw_doc_chain(figs, ALICE_START_POINT, {'3', '4'})
table.insert(figs, luamp.arrow(alice, alice_docs[1], {pen_color=luamp.colors.red}))

local ALAN_START_POINT = luamp.point(3, 1)
local alan_docs = draw_doc_chain(figs, ALAN_START_POINT, {'1', '2', '3'})
table.insert(figs, luamp.arrow(alan, alan_docs[1], {pen_color=luamp.colors.red}))

print(luamp.figure(table.unpack(figs)))
