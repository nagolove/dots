#!/usr/bin/env lua

local tabular = require "tabular"
local inspect = require "inspect"

local function load_dot(fname)
    local res = {}
    local ok, errmsg = pcall(function()
        local file = io.open(fname, "r")
        for line in file:lines() do
            from, to  = string.match(line, "(%d+)%s*%->%s*(%d+)%s*;")
            if from and to then
                table.insert(res, {tonumber(from), tonumber(to)})
            end
            print('from', from, 'to', to)
        end
    end)

    if not ok then
        print('load_dot() failed with', errmsg)
        os.exit(1)
    end

    return res
end

local function change_name(fname)
    return string.gsub(fname, "(.*)%.dot$", "%1_sorted.dot")
end

local format = string.format

local function print_sorted(sorted)
    for k, v in ipairs(sorted) do
        print(v.value)
        print("#v.childs", #v.childs)
    end
end

local function save_dot(fname, sorted)
    print('save_dot', fname)
    local ok, errmsg = pcall(function()
        local file = io.open(fname, "w")
        file:write("digraph graphname {\n")
        for index, node in ipairs(sorted) do
            local to = node.childs and node.childs[1].value or -1
            local line = format(
                "%d -> %d [label = \"%d\"]\n", 
                node.value,
                to,
                index
            )
            file:write(line)
        end
        file:write("}")
    end)
    if not ok then
        print('save_dot failed with', errmsg)
        os.exit(1)
    end
end

local function visit(sorted, node)
    print('visit', node)
    if node.permament then
        return
    end
    if node.temporary then
        print('Cycle found')
        print('node', inspect(node.value))
        os.exit(1)
    end
    node.temporary = true
    for _, child in pairs(node.childs) do
        visit(sorted, child)
    end
    node.temporary = nil
    node.permament = true
    table.insert(sorted, 1, node)
end

local function main()
    if not arg[1] then
        print("Please specify dot file with graph")
        os.exit(1)
        return
    end

    local _pairs = load_dot(arg[1])
    --print(inspect(_pairs))
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

    local sorted = {}
    --print(inspect(T[3]))
    local visited = false
    --repeat
        --visited = false
        for k, node in pairs(T) do
            --if not node.permament and not node.temporary then
            if not node.permament then
                visited = true
                visit(sorted, node)
            end
        end
    --until visited

    print('sorted')
    print(inspect(sorted))
    print_sorted(sorted)
    --save_dot(change_name(arg[1]), sorted)
end

if arg then
    main()
end
