local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.enable_wayland = false
config.color_scheme = 'Nord (base16)'
config.harfbuzz_features = { 'liga=0', 'clig=0', 'calt=0' }
config.hide_tab_bar_if_only_one_tab = true

local is_apple = string.find(wezterm.target_triple, 'apple', 1, true) ~= nil

if not is_apple then
  -- Ensure IME works under XWayland/X11 on Linux
  config.use_ime = true
  config.xim_im_name = 'fcitx'
end

local function platform_font()
  if is_apple then
    return wezterm.font_with_fallback {
      'D2CodingLigature Nerd Font',
      'JetBrainsMono Nerd Font',
      'Menlo',
    }
  end
  return wezterm.font_with_fallback {
    'D2CodingLigature Nerd Font',
    'JetBrainsMono Nerd Font',
    'DejaVu Sans Mono',
  }
end

config.font = platform_font()
if is_apple then
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
