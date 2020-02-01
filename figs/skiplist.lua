package.path = package.path .. ';lib/?.lua'
local luamp = require 'luamp'
local stream = require 'stream'
local table = require 'table'
local skiplist = require 'skiplist_lib'

local figs = {}

skiplist.draw_doc_chain(figs, luamp.origin, {'1', '2', '3', '4', '5', '6', '7', '8', '9'})

print(luamp.figure(table.unpack(figs)))
