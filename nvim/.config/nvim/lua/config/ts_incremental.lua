-- Minimal treesitter "incremental selection", since the nvim-treesitter `main`
-- branch removed the built-in module and it was never ported to textobjects.
-- Grows/shrinks a Visual selection along the syntax tree.
local M = {}

-- per-buffer stack of node ranges: { srow, scol, erow, ecol } (0-indexed, end-exclusive)
local stacks = {}

local function get_node_at_cursor()
    local ok, node = pcall(vim.treesitter.get_node)
    if not ok then
        return nil
    end
    return node
end

-- Visually select a 0-indexed, end-exclusive range.
local function select_range(range)
    local srow, scol, erow, ecol = range[1], range[2], range[3], range[4]
    -- end-exclusive -> inclusive last position
    if ecol == 0 then
        erow = erow - 1
        local line = vim.api.nvim_buf_get_lines(0, erow, erow + 1, false)[1] or ""
        ecol = #line
    end
    if ecol > 0 then
        ecol = ecol - 1
    end
    vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
    vim.cmd("normal! v")
    vim.api.nvim_win_set_cursor(0, { erow + 1, ecol })
end

local function range_of(node)
    local srow, scol, erow, ecol = node:range()
    return { srow, scol, erow, ecol }
end

local function same_range(a, b)
    return a[1] == b[1] and a[2] == b[2] and a[3] == b[3] and a[4] == b[4]
end

function M.init_selection()
    local buf = vim.api.nvim_get_current_buf()
    local node = get_node_at_cursor()
    if not node then
        return
    end
    stacks[buf] = { range_of(node) }
    select_range(stacks[buf][#stacks[buf]])
end

-- Grow to the smallest ancestor whose range is strictly larger than current.
function M.node_incremental()
    local buf = vim.api.nvim_get_current_buf()
    local stack = stacks[buf]
    if not stack or #stack == 0 then
        return M.init_selection()
    end
    local cur = stack[#stack]
    local node = get_node_at_cursor()
    if not node then
        return
    end
    -- climb until the range changes
    while node do
        local r = range_of(node)
        if not same_range(r, cur) then
            table.insert(stack, r)
            select_range(r)
            return
        end
        node = node:parent()
    end
end

function M.node_decremental()
    local buf = vim.api.nvim_get_current_buf()
    local stack = stacks[buf]
    if not stack or #stack <= 1 then
        return
    end
    table.remove(stack)
    select_range(stack[#stack])
end

-- Grow to the next named ancestor (a coarser "scope" jump).
function M.scope_incremental()
    local buf = vim.api.nvim_get_current_buf()
    local stack = stacks[buf]
    if not stack or #stack == 0 then
        M.init_selection()
        stack = stacks[buf]
    end
    local cur = stack[#stack]
    local node = get_node_at_cursor()
    while node do
        local r = range_of(node)
        if node:named() and not same_range(r, cur) then
            table.insert(stack, r)
            select_range(r)
            return
        end
        node = node:parent()
    end
end

return M
