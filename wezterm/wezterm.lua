local wezterm = require 'wezterm'

local config = wezterm.config_builder()

local solarized_osaka = {
  foreground = '#839395',
  background = '#001419',
  cursor_bg = '#839395',
  cursor_border = '#839395',
  cursor_fg = '#001419',
  selection_bg = '#002c38',
  selection_fg = '#839395',
  ansi = {
    '#001014',
    '#db302d',
    '#849900',
    '#b28500',
    '#268bd3',
    '#d23681',
    '#29a298',
    '#9eabac',
  },
  brights = {
    '#576d74',
    '#db302d',
    '#849900',
    '#b28500',
    '#268bd3',
    '#d23681',
    '#29a298',
    '#839395',
  },
  tab_bar = {
    inactive_tab_edge = '#002c38',
    background = '#191b28',
    active_tab = {
      fg_color = '#268bd3',
      bg_color = '#001419',
    },
    inactive_tab = {
      bg_color = '#002c38',
      fg_color = '#637981',
    },
    inactive_tab_hover = {
      bg_color = '#002c38',
      fg_color = '#268bd3',
    },
    new_tab = {
      fg_color = '#268bd3',
      bg_color = '#191b28',
    },
    new_tab_hover = {
      fg_color = '#002c38',
      bg_color = '#268bd3',
    },
  },
}

-- Wayland-native (text-input-v3). If IME desync regresses, set back to
-- false and see the rollback checklist in docs/wezterm-wayland.md.
config.enable_wayland = true
config.color_schemes = {
  ['Solarized Osaka Dark'] = solarized_osaka,
}
config.color_scheme = 'Solarized Osaka Dark'
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
