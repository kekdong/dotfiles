-- Neovim configuration migrated from legacy vimrc with Nord theme

-- Set leader early so plugin keymaps use it
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "shaunsingh/nord.nvim",
    priority = 1000,
    config = function()
      vim.g.nord_contrast = true
      vim.g.nord_borders = true
      vim.g.nord_disable_background = false
      vim.opt.termguicolors = true
      vim.cmd.colorscheme("nord")
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end,  desc = "Live grep" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end,    desc = "Buffers" },
      { "<leader>fh", function() require("telescope.builtin").help_tags() end,  desc = "Help tags" },
    },
    opts = function()
      return {
        defaults = {
          prompt_prefix = "  ",
          selection_caret = "> ",
          sorting_strategy = "ascending",
          layout_strategy = "flex",
          layout_config = { prompt_position = "top", width = 0.95, height = 0.90 },
        },
        extensions = {
          fzf = { fuzzy = true, case_mode = "smart_case" },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = function()
      return vim.fn.executable("make") == 1
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "nord",
          section_separators = "",
          component_separators = "",
        },
      })
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({})
    end,
    keys = {
      { "<leader>n", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      {
        "OXY2DEV/markview.nvim",
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
          preview = {
            icon_provider = "devicons",
            enable_hybrid_mode = true,
            hybrid_modes = { "n", "i" },
            linewise_hybrid_mode = true,
            edit_range = { 2, 2 },
          },
        },
        config = function(_, opts)
          require("markview").setup(opts)
        end,
      },
    },
    opts = {
      ensure_installed = { "lua", "markdown", "markdown_inline", "html" },
      highlight = { enable = true },
      indent = { enable = true, disable = { "markdown" } },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "renerocksai/telekasten.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "renerocksai/calendar-vim" },
    keys = {
      { "<leader>zz", function() require("telekasten").panel() end,        desc = "Telekasten panel" },
      { "<leader>zn", function() require("telekasten").new_note() end,      desc = "New note" },
      { "<leader>zd", function() require("telekasten").goto_today() end,    desc = "Today (daily)" },
      { "<leader>zf", function() require("telekasten").find_notes() end,    desc = "Find notes" },
      { "<leader>zg", function() require("telekasten").search_notes() end,  desc = "Grep notes" },
    },
    opts = function()
      local vault = vim.env.TELEKASTEN_VAULT
      if not vault or vault == "" then
        local candidates = { "~/Workspace/Commonplace-Book", "~/Workspace/Commonpalce-Book" }
        for _, c in ipairs(candidates) do
          local p = vim.fn.expand(c)
          if vim.fn.isdirectory(p) == 1 then
            vault = p
            break
          end
        end
        if not vault or vault == "" then
          vault = vim.fn.expand(candidates[#candidates])
        end
      else
        vault = vim.fn.expand(vault)
      end
      return {
        home = vault,
        -- Align with existing Obsidian settings
        dailies = "Areas/Journal/Daily",
        weeklies = "Areas/Journal/Weekly",
        templates = "Resources/Templates",
        new_note_filename = "title",   -- ask for a title
        uuid_type = "datetime",
        template_new_note = "default-note.md",
        template_new_daily = "dailynote.md",
      }
    end,
    config = function(_, opts)
      require("telekasten").setup(opts)
    end,
  },
  {
    "tpope/vim-fugitive",
  },
  {
    "lewis6991/gitsigns.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitsigns").setup()
    end,
  },
})

-- General options
local opt = vim.opt
opt.number = true
opt.showcmd = true
opt.cursorline = true
opt.showmatch = true
opt.scrolloff = 3
opt.ruler = true
opt.expandtab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.smartindent = true
opt.autoindent = true
opt.incsearch = true
opt.hlsearch = true
opt.backspace = "start,indent,eol"
opt.clipboard = "unnamedplus"
opt.updatetime = 300

-- Keymaps
local keymap = vim.keymap
keymap.set("n", "j", "gj")
keymap.set("n", "k", "gk")
keymap.set("i", "jk", "<Esc>")
keymap.set("n", "<leader>w", ":w<CR>")
keymap.set("n", "<leader>q", ":q<CR>")

-- Highlight last inserted text
keymap.set("n", "gV", "`[v`]")
