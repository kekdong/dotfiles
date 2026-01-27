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
