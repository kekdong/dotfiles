local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- Default to XWayland for IME/focus stability on KDE Wayland.
-- Re-evaluate Wayland with the checklist in docs/wezterm-wayland.md.
config.enable_wayland = false
config.color_scheme = 'Nord (base16)'
config.harfbuzz_features = { 'liga=0', 'clig=0', 'calt=0' }
config.hide_tab_bar_if_only_one_tab = true

local is_apple = string.find(wezterm.target_triple, 'apple', 1, true) ~= nil
local is_wayland = config.enable_wayland

if not is_apple then
  -- Enable IME and keep preedit anchored in terminal cells on Linux.
  config.use_ime = true
  config.ime_preedit_rendering = 'Builtin'

  -- XIM is only relevant for X11/XWayland sessions.
  if not is_wayland then
    config.xim_im_name = 'fcitx'
  end
end

local function platform_font()
  if is_apple then
    return wezterm.font_with_fallback {
      -- macOS: prefer Term variant from jonz94 tap; also allow Mono
      'Sarasa Term K Nerd Font',
      'Sarasa Term J Nerd Font',
      'Sarasa Term SC Nerd Font',
      'Sarasa Term TC Nerd Font',
      'Sarasa Mono K Nerd Font',
      'Sarasa Mono J Nerd Font',
      'Sarasa Mono SC Nerd Font',
      'Sarasa Mono TC Nerd Font',
      -- Fallbacks
      'JetBrainsMono Nerd Font',
      'Menlo',
    }
  end
  return wezterm.font_with_fallback {
    -- Linux: prefer Term variants; include laishulu AUR naming
    'Sarasa Term K Nerd Font',
    'Sarasa Term J Nerd Font',
    'Sarasa Term SC Nerd Font',
    'Sarasa Term TC Nerd Font',
    'Sarasa Term SC Nerd', -- AUR nerd-fonts-sarasa-term family name
    -- Also accept Mono if installed
    'Sarasa Mono K Nerd Font',
    'Sarasa Mono J Nerd Font',
    'Sarasa Mono SC Nerd Font',
    'Sarasa Mono TC Nerd Font',
    -- Fallbacks
    'JetBrainsMono Nerd Font',
    'DejaVu Sans Mono',
  }
end

config.font = platform_font()
if is_apple then
  -- Ensure macOS uses native IME and that IME commits before newline
  -- This helps prevent the last Hangul syllable from wrapping onto the next line
  -- when pressing Enter at EOL in some shells/apps.
  config.use_ime = true
  -- Forward Shift and Ctrl to IME so Shift+Space (input source toggle)
  -- and Ctrl+J (newline in some apps) both commit IME composition first.
  config.macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'
  config.native_macos_fullscreen_mode = true
  config.font_size = 14.0
end

local nord = {
  polar0 = '#2E3440',
  polar1 = '#3B4252',
  polar2 = '#434C5E',
  polar3 = '#4C566A',
  frost1 = '#81A1C1',
  frost2 = '#88C0D0',
  snow1 = '#E5E9F0',
  snow2 = '#ECEFF4',
}

config.colors = {
  tab_bar = {
    background = nord.polar0,
    inactive_tab_edge = nord.polar1,
    active_tab = {
      bg_color = nord.polar2,
      fg_color = nord.snow2,
      intensity = 'Normal',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },
    inactive_tab = {
      bg_color = nord.polar0,
      fg_color = nord.snow1,
    },
    inactive_tab_hover = {
      bg_color = nord.polar1,
      fg_color = nord.snow2,
      italic = false,
    },
    new_tab = {
      bg_color = nord.polar0,
      fg_color = nord.frost1,
    },
    new_tab_hover = {
      bg_color = nord.polar1,
      fg_color = nord.frost2,
      italic = false,
    },
  },
}

if is_apple then
  wezterm.on('user-var-changed', function(window, pane, name, value)
    if name == 'nvim_mode' and value == 'normal' then
      local im_select = wezterm.which('im-select')
      if im_select then
        wezterm.run_child_process({ im_select, 'com.apple.keylayout.ABC' })
      end
    end
  end)
end

wezterm.on('gui-startup', function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  local gui_window = window:gui_window()

  -- keep prior behavior of starting fullscreen
  if gui_window then
    wezterm.time.call_after(0.1, function()
      gui_window:toggle_fullscreen()
    end)
  end
end)

return config
