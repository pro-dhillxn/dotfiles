local function make_mapper(path_type)
    return function()
        local path
        if path_type == "abs" then
            path = vim.fn.expand("%:p")
        elseif path_type == "rel" then
            path = vim.fn.expand("%")
        else
            error("path_type must be either 'abs' or 'rel'")
        end

        local regions = vim.fn.getregionpos(vim.fn.getpos("v"), vim.fn.getpos("."))
        local s = regions[1][1]        -- start pos of 1st selected line
        local e = regions[#regions][2] -- end pos of last selected line

        local mode = vim.fn.mode()
        local selection_str


        local sl, sc = s[2], s[3] -- start, end of the start
        local el, ec = e[2], e[3]
        if mode == "v" then
            selection_str = string.format("%s:%s:%s-%s:%s", path, sl, sc,
                el,
                ec)
        elseif mode == "V" or mode == "\22" then -- will mostly use v-block for edits and not selectins
            selection_str = string.format("%s:%s-%s", path, sl, el)
        end
        vim.fn.setreg("+", selection_str)
        vim.notify("yanked: " .. selection_str)
    end
end


vim.keymap.set("x", "<leader>sr", make_mapper("rel"), { desc = "get selection with relative file path" })
vim.keymap.set("x", "<leader>sa", make_mapper("abs"), { desc = "get selection with absolute file path" })
