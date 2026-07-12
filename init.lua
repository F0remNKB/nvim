vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.g.neovide_scale_factor = 0.8
vim.g.mapleader = " "

if vim.fn.has("win32") == 1 then
    vim.opt.shell = "powershell"
    vim.opt.shellcmdflag = "-command"
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "olimorris/onedarkpro.nvim",
        priority = 1000,
        config = function()
            require("onedarkpro").setup({
                colors = {
                    onedark_dark = { bg = "#181818" },
                },
                highlights = {
                    ["Macro"] = { fg = "#ef596f" },
                    ["@constant"] = { fg = "#ef596f" },
                    ["@lsp.type.macro.rust"] = { fg = "#ef596f" },
                    ["Function"] = { fg = "#61afef" },
                    ["@function.method"] = { fg = "#61afef" },
                    ["@function.method.call"] = { fg = "#61afef" },
                    ["@function.builtin"] = { fg = "#61afef" },
                    ["@lsp.typemod.method.defaultLibrary.rust"] = { fg = "#61afef" },
                    ["@variable"] = { fg = "#abb2bf" },
                },
                styles = {
                    comments = "italic",
                },
            })
            vim.cmd("colorscheme onedark_dark")
        end,
    },

    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    {
        "williamboman/mason.nvim",
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = { "rust_analyzer", "vtsls", "pyright", "html-lsp" },
        },
    },
    { "neovim/nvim-lspconfig" },

    { "rafamadriz/friendly-snippets" },
    {
        "saghen/blink.cmp",
        version = "1.*",
        opts = {
            keymap = { preset = "super-tab" },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            completion = {
                documentation = { auto_show = true },
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
        config = function()
            require("nvim-treesitter").setup()
            require("nvim-treesitter").install({ "rust", "lua", "python" })
        end,
    },

    {
        "nvim-lualine/lualine.nvim",
        opts = {},
    },
    {
        "akinsho/bufferline.nvim",
        version = "*",
        opts = {},
    },

    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        opts = {
            filesystem = {
                bind_to_cwd = false,
                follow_current_file = { enabled = true },
                use_libuv_file_watcher = true,
                filtered_items = {
                    visible = true,
                    hide_dotfiles = false,
                    hide_gitignored = false,
                },
            },
            window = {
                mappings = {
                    ["l"] = "open",
                    ["h"] = "close_node",
                },
            },
        },
    },

    {
        "coffebar/neovim-project",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
            "Shatur/neovim-session-manager",
        },
        opts = {
            projects = {
                "C:/Users/okibo/AppData/Local/nvim",
                "C:/Users/okibo/OneDrive/Projects//*",
            },
        },
    },
    { "Shatur/neovim-session-manager" },

    {
        "lewis6991/gitsigns.nvim",
        opts = {},
    },
    { "tpope/vim-fugitive" },

    {
        "altermo/ultimate-autopair.nvim",
        event = "InsertEnter",
        opts = {},
    },

    {
        "ahmedkhalf/project.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        config = function()
            require("project_nvim").setup()
            require("telescope").load_extension("projects")
        end,
    },

    {
        "nvzone/menu",
        dependencies = { "nvzone/volt" },
    },

    {
        "kylechui/nvim-surround",
        opts = {},
    },

    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")
            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = vim.fn.stdpath("data") .. "/mason/bin/codelldb.cmd",
                    args = { "--port", "${port}" },
                },
            }
            dap.configurations.rust = {
                {
                    name = "Debug",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        local cwd = vim.fn.getcwd()
                        local project_name = vim.fn.fnamemodify(cwd, ":t")
                        return cwd .. "/target/debug/" .. project_name .. ".exe"
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                },
            }
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        main = "dapui",
        opts = {},
    },

    {
        "folke/trouble.nvim",
        opts = {},
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
    },
})

local capabilities = require("blink.cmp").get_lsp_capabilities()
vim.lsp.config("rust_analyzer", { capabilities = capabilities })
vim.lsp.enable("rust_analyzer")
vim.lsp.config("vtsls", { capabilities = capabilities })
vim.lsp.enable("vtsls")
vim.lsp.config("pyright", { capabilities = capabilities })
vim.lsp.enable("pyright")

vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        require("session_manager").save_current_session()
    end,
})

vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>o", "o<Esc>", { desc = "New line below" })
vim.keymap.set("n", "<leader>O", "O<Esc>", { desc = "New line above" })
vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>")
vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>")
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>x", ":bd<CR>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>fp", ":NeovimProjectDiscover<CR>", { desc = "Projects" })
vim.keymap.set("n", "<leader>fh", ":Telescope projects<CR>")
vim.keymap.set("n", "<leader>cd", ":cd %:h<CR>", { desc = "CD to current file" })
vim.keymap.set("n", "<leader>vc", ":e $MYVIMRC<CR>", { desc = "Open config" })
vim.keymap.set("n", "<leader>m", function()
    require("menu").open("default")
end)
vim.keymap.set("n", "<leader>rn", ":set relativenumber!<CR>")
vim.keymap.set("n", "<leader>db", ":DapToggleBreakpoint<CR>", { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dc", ":DapContinue<CR>", { desc = "Continue" })
vim.keymap.set("n", "<leader>ds", ":DapTerminate<CR>", { desc = "Stop" })
vim.keymap.set("n", "<leader>du", ":lua require('dapui').toggle()<CR>", { desc = "DAP UI" })
vim.keymap.set("n", "<leader>td", ":Trouble diagnostics toggle<CR>", { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>F", vim.lsp.buf.format, { desc = "Format" })
vim.keymap.set("n", "<leader>E", ":Ex<CR>", { desc = "Explorer" })
