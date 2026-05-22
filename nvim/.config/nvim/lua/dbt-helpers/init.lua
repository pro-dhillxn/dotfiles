local M = {}

-- Cache for model list to improve performance
local _model_cache = nil
local _dbt_root_cache = nil

-- ============================================================================
-- Helper Functions (must be defined before public functions use them)
-- ============================================================================

local function get_project_root()
    local root_path = vim.fn.system("git rev-parse --show-toplevel")
    return vim.fn.trim(root_path)
end

-- Find dbt project root by searching from git root
local function find_dbt_project_root()
    local git_root = get_project_root()

    if git_root == "" or git_root:match("^fatal:") then
        return nil
    end

    -- Search for dbt_project.yml or dbt_project.yaml, excluding virtual environments
    local find_cmd = string.format(
        'find "%s" -type f \\( -name "dbt_project.yml" -o -name "dbt_project.yaml" \\) ! -path "*/.venv/*" ! -path "*/venv/*" ! -path "*/.env/*" ! -path "*/env/*" ! -path "*/node_modules/*" -print -quit',
        git_root
    )
    local dbt_project_file = vim.fn.system(find_cmd)
    dbt_project_file = vim.fn.trim(dbt_project_file)

    if dbt_project_file == "" then
        return nil
    end

    -- Return the directory containing the dbt_project file
    return vim.fn.fnamemodify(dbt_project_file, ":h")
end

-- Get all dbt model files from the models directory
local function get_dbt_models(dbt_root)
    local models_dir = dbt_root .. "/src"

    -- Find all .sql files, excluding common dbt directories
    local find_cmd = string.format(
        'find "%s" -type f -name "*.sql" ! -path "*/target/*" ! -path "*/dbt_packages/*" ! -path "*/logs/*" ! -path "*/dbt_modules/*" ! -path "*/tests/*" ! -path "*/.venv/*" ! -path "*/venv/*" 2>/dev/null',
        models_dir
    )

    local result = vim.fn.system(find_cmd)
    result = vim.fn.trim(result)

    if result == "" then
        return {}
    end

    -- Split by newlines to get array of file paths
    local files = vim.split(result, "\n")
    return files
end

-- Extract model name with parent directory for display
-- e.g., "models/staging/stg_customers.sql" -> "staging/stg_customers"
local function extract_model_name_with_parent(filepath)
    -- Remove .sql extension
    local without_ext = filepath:gsub("%.sql$", "")

    -- Split path into parts
    local parts = vim.split(without_ext, "/")

    -- Get the last two parts (parent_dir/model_name)
    if #parts >= 2 then
        return parts[#parts - 1] .. "/" .. parts[#parts]
    elseif #parts == 1 then
        return parts[1]
    else
        return filepath
    end
end

-- Extract just the model name (without path or extension)
local function extract_model_name(filepath)
    local filename = vim.fn.fnamemodify(filepath, ":t")
    return filename:gsub("%.sql$", "")
end

-- ============================================================================
-- Public Functions
-- ============================================================================

function M.insert_source()
    local source_name = vim.fn.input("Insert source name: ")
    local table_name = vim.fn.input("Insert table name: ")
    if source_name == "" or table_name == "" then
        print("Source name or table name cannot be empty.")
        return
    end
    local final_str = "{{ source('" .. source_name .. "','" .. table_name .. "') }}"
    vim.api.nvim_put({ final_str }, "c", true, true)
end

function M.insert_ref()
    local ref_name = vim.fn.input("Insert ref name: ")
    local final_str = "{{ ref('" .. ref_name .. "') }}"
    vim.api.nvim_put({ final_str }, "c", true, true)
end

-- Interactive ref insertion with model picker
function M.insert_ref_interactive()
    -- Check cache first
    local dbt_root = _dbt_root_cache
    local models = _model_cache

    if not dbt_root or not models then
        -- Find dbt project root
        dbt_root = find_dbt_project_root()

        if not dbt_root then
            vim.notify("Not in a dbt project. Could not find dbt_project.yml", vim.log.levels.ERROR)
            return
        end

        -- Get all models
        models = get_dbt_models(dbt_root)

        if #models == 0 then
            vim.notify("No models found in " .. dbt_root .. "/models", vim.log.levels.WARN)
            return
        end

        -- Cache the results
        _dbt_root_cache = dbt_root
        _model_cache = models
    end

    -- Build display options with parent directory
    local display_items = {}
    local model_map = {}

    for _, filepath in ipairs(models) do
        local display_name = extract_model_name_with_parent(filepath)
        local model_name = extract_model_name(filepath)
        table.insert(display_items, display_name)
        model_map[display_name] = model_name
    end

    -- Show picker
    vim.ui.select(display_items, {
        prompt = "Select model to ref:",
        format_item = function(item)
            return item
        end,
    }, function(choice)
        if choice then
            local model_name = model_map[choice]
            local final_str = "{{ ref('" .. model_name .. "') }}"
            vim.api.nvim_put({ final_str }, "c", true, true)
        end
    end)
end

-- Refresh the model cache
function M.refresh_model_cache()
    _model_cache = nil
    _dbt_root_cache = nil
    vim.notify("dbt model cache cleared", vim.log.levels.INFO)
end

function M.is_dbt_project()
    local dbt_root = find_dbt_project_root()
    return dbt_root ~= nil
end

return M
