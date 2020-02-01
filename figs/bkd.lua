package.path = package.path .. ';lib/?.lua'
local luamp = require 'luamp'
local stream = require 'stream'
local table = require 'table'
local skiplist = require 'skiplist_lib'

local draw_doc_chain = skiplist.draw_doc_chain

local tree = luamp.layouts.tree(
    luamp.origin,
    1.5,
    2,
    {false,
        {false},
        {false}})

local root = luamp.rectangle(tree[1], 1, 0.5)
local left = luamp.rectangle(tree[2][1], 1, 0.5)
local right = luamp.rectangle(tree[3][1], 1, 0.5)

local figs = {}

table.insert(figs, luamp.line(root, left))
table.insert(figs, luamp.line(root, right))
table.insert(figs, luamp.text(root:center(), luamp.directions.center, '[18,21]'))
table.insert(
    figs,
    luamp.text(
        left:center(), luamp.directions.center, '[18,18]',
        {pen_color=luamp.colors.red}))
table.insert(
    figs,
    luamp.text(
        right:center(), luamp.directions.center, '[20,21]',
        {pen_color=luamp.colors.red}))

local left_docs = draw_doc_chain(figs, luamp.point(3, 1), {'0', '4'})
table.insert(figs, luamp.arrow(left, left_docs[1], {pen_color=luamp.colors.red}))
local right_docs = draw_doc_chain(figs, luamp.point(3, -1), {'1', '2', '3'})
table.insert(figs, luamp.arrow(right, right_docs[1], {pen_color=luamp.colors.red}))

print(luamp.figure(table.unpack(figs)))
