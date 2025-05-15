-- Integration with spacian.jumplist extension
-- This prevents C-u and C-d from polluting the jumplist

if vim.g.vscode then
    local vscode = require("vscode-neovim")
    local previous_jumplist_state = vim.fn.getjumplist()[1] -- Get the actual list of jumps

    local function jump_back()
        vscode.call("jumplist.jumpBack")
    end

    local function jump_forw()
        vscode.call("jumplist.jumpForward")
    end

    -- This is a more robust way to handle go to definition
    local function goToDef()
        -- Manually register a jump with spacian.jumplist BEFORE navigating
        vscode.call("jumplist.registerJump")
        -- Then perform the VSCode action for go to definition
        vscode.call("editor.action.revealDefinition")

        -- Update our local state of the jumplist after a short delay
        vim.defer_fn(function()
            previous_jumplist_state = vim.fn.getjumplist()[1]
        end, 100) -- Adjust delay if needed
    end

    -- Override C-o and C-i to use spacian.jumplist
    vim.keymap.set({ "n" }, "<C-o>", jump_back, { noremap = true, silent = true, desc = "Jumplist Back (Spacian)" })
    vim.keymap.set({ "n" }, "<C-i>", jump_forw, { noremap = true, silent = true, desc = "Jumplist Forward (Spacian)" })

    -- Map gd to use our custom goToDef function
    vim.keymap.set({ "n" }, "gd", goToDef, { noremap = true, silent = true, desc = "Go to Definition (Spacian Jump)" })

    -- Periodically sync Neovim's jumps to spacian.jumplist
    local function sync_nvim_jumps_to_spacian()
        local current_jumplist_state = vim.fn.getjumplist()[1]
        -- Check if new jumps were added in Neovim since last check
        if #current_jumplist_state > #previous_jumplist_state then
            -- Register the current position in spacian.jumplist if Neovim's list grew
            vscode.call("jumplist.registerJump")
        end
        previous_jumplist_state = current_jumplist_state
    end

    -- You could set up an autocmd to call sync_nvim_jumps_to_spacian periodically
    -- or on specific events if needed
    vim.api.nvim_create_autocmd({"CursorHold"}, {
        callback = function()
            sync_nvim_jumps_to_spacian()
        end,
    })
end