# WezTerm on KDE Wayland (NVIDIA): install & fallback

This repo includes a `wezterm/wezterm.lua` config. On KDE Plasma Wayland with NVIDIA, older WezTerm builds may exit at startup with Wayland protocol errors (often around explicit sync). Using a newer WezTerm build (AUR `-git`/nightly) can resolve it.

## Install via yay (AUR)

1) Remove the repo build (optional but recommended to avoid confusion):

```bash
sudo pacman -Rns wezterm
```

2) Install one of the following:

- Nightly binary (fastest to install/update):

```bash
yay -S wezterm-nightly-bin
```

- Git build (newest source, slower builds):

```bash
yay -S wezterm-git
```

3) Keep it updated:

```bash
yay -Syu
```

4) Verify:

```bash
wezterm --version
```

## Wayland enable + emergency fallback

- Enable Wayland in config: set `config.enable_wayland = true` in `wezterm/wezterm.lua`.
- If it crashes on Wayland, force X11/XWayland for that run:

```bash
WINIT_UNIX_BACKEND=x11 wezterm
```

## Notes

- To confirm you are in a Wayland session:

```bash
echo $XDG_SESSION_TYPE
```

- When reporting crashes, run with:

```bash
RUST_BACKTRACE=1 wezterm start --always-new-process
```

## Wayland Re-enable Checklist (IME/Focus Regression)

Current default in this repo is `config.enable_wayland = false` due to intermittent IME desync after app/workspace switches (notably returning from Chromium).

When trying Wayland again, run this checklist before keeping the change.

1) Switch config

```lua
config.enable_wayland = true
```

2) Restart WezTerm fully (close all windows) and verify backend

```bash
xlsclients | rg -i wezterm || echo "No X11 client (likely Wayland-native)"
```

3) Core IME test (`Shift+Space`)
- In WezTerm: toggle Korean/English 20+ times while typing in shell and Neovim.
- Expected: no missed toggles, no stuck English-only state.

4) Focus transition stress test
- Sequence: `WezTerm -> Chromium -> another workspace -> WezTerm`.
- Repeat 20+ cycles.
- Expected: first `Shift+Space` works immediately after returning to WezTerm.

5) Preedit/candidate position test
- While composing Hangul near end-of-line and after scrolling:
- Expected: preedit/candidate UI stays anchored to text, not detached below.

6) Multi-tab/workspace test in WezTerm
- Switch tabs/panes/workspaces while composition is active.
- Expected: composition state remains consistent and committed text is correct.

7) Capture diagnostics if any failure appears

```bash
wezterm --version
qdbus6 org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1.DebugInfo | sed -n '1,200p'
fcitx5-remote
fcitx5-remote -n
```

8) Rollback rule
- If any regression is reproducible, revert to:

```lua
config.enable_wayland = false
```
