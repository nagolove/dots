#!/usr/bin/env lua

local tabular = require "tabular"
local inspect = require "inspect"

local function load_dot(fname)
    local res = {}
    local file = io.open(fname, "r")
    for line in file:lines() do
        from, to  = string.match(line, "(%d+)%s%->%s(%d+)")
        if from and to then
            table.insert(res, {tonumber(from), tonumber(to)})
        end
        --print('from', from, 'to', to)
    end
    return res
end

local function add(node, _pairs)
end

local function main()
    if arg[1] then
        local _pairs = load_dot(arg[1])
        print(inspect(_pairs))
        local T = {}
        for _, pair in pairs(_pairs) do
            local from = pair[1]
            local to = pair[2]
            if not T[from] then
                T[from] = {
                    value = from,
                    parents = {},
                    childs = {}
                }
            end
            if not T[to] then
                T[to] = {
                    value = to,
                    parents = {},
                    childs = {},
                }
            end
            local node_from = T[from]
            local node_to = T[to]

            table.insert(node_from.childs, node_to)
            table.insert(node_to.parents, node_from)
        end

    end
end

if arg then
    main()
end
