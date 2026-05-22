return {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup()
    end
}

-- So in defaults, `ys` is the operator for "surrounds"
-- ysiw" : Surround inner word with "
-- ysiw(: Surround inner word with space on the ends; ysiw): for just surroung with no space. Same for other parenthesis
-- yss) : Surround entire line with ()
-- cs"' : Change Surrounding "  to '
-- ds" : Delete surrounds "
-- S" : VISUAL MODE - Surround Selection with "
