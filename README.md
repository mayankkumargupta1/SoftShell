# SoftShell

A pixel-refined desktop environment layer for **Hyprland** built with **Quickshell** and **QML**.

Features an authentic Dynamic Island, translucent frosted glass Menu Bar, application launcher, live media visualizer, and clipboard popover.

---

## Features

- **SoftShell Menu Bar**:
  - Translucent frosted glass material with Hyprland layer blur.
  - Left: SoftShell logo, active application title in bold, standard menu bar items (`File`, `Edit`, `View`, `Go`, `Tools`, `Window`, `Help`).
  - Right: SoftShell status icons — Battery pill with dynamic fill level, 3-arc Wi-Fi signal glyph, and double-toggle Control Center switch (`SF Symbol switch.2`).
  - Safe central cutout reserved for the Dynamic Island.
- **Dynamic Island (Top Overlay)**:
  - AMOLED pitch-black pill smoothly animating between collapsed, expanded, media, and notification states.
  - Spring-physics animations for fluid expansion and collapse.
  - Interactive music visualizer, Spotify / MPRIS controls, and vinyl playback animation.
  - Notification banner integration with queue counter and quick dismissal.
  - Visual clipboard copy animation response.
- **App Launcher**:
  - SoftShell launcher aesthetic with frosted glass, squircle icons, keyboard navigation, and fuzzy desktop app search.
  - Toggled with `Super + A` or `Super + D`.

---

## Requirements & Dependencies

- **OS**: Arch Linux (or any Wayland desktop with Hyprland)
- **Shell**: `quickshell`
- **Compositor**: `hyprland`
- **Audio / Media**: `wireplumber`, `pipewire`, `playerctl`
- **Hardware / Utilities**: `brightnessctl`, `wl-clipboard`, `cliphist`, `grim`, `slurp`
- **Fonts**: `ttf-jetbrains-mono-nerd`, `noto-fonts` (or `SF Pro Display`)

---

## Installation

Run the automated installer script:

```bash
chmod +x install.sh
./install.sh
```

### Installer Options
- `./install.sh`: Full install — verifies dependencies, backs up existing configurations, deploys SoftShell to `~/.config/quickshell`, sets up Hyprland keybinds/layer rules, and triggers live switchover.
- `./install.sh --check-deps`: Check for missing packages.
- `./install.sh --no-switch`: Deploy configs without stopping or starting live processes.

---

## Keybindings (Hyprland)

| Keybinding | Action |
|---|---|
| `Super + A` / `Super + D` | Toggle App Launcher |
| `Super + R` | Reload SoftShell (`quickshell`) |
| `Super + Space` | Play / Pause active media |
| `Print` | Interactive area screenshot to clipboard (`grim + slurp`) |

---

## Architecture & Modularization

All components follow strict modular single-responsibility design guidelines:

```
├── shell.qml                   # Main entrypoint: loads panels and overlays
├── theme/                      # Styling tokens, colors, typography, metrics
│   ├── Theme.qml               # Singleton for global style tokens
│   └── qmldir
├── components/                 # Reusable generic UI primitives
├── widgets/                    # Domain-specific shell widgets
│   ├── bar/                    # Menu bar items (App menu, Status icons)
│   ├── clock/                  # Compact and expanded clocks
│   ├── mpris/                  # Media player controller and visualizer
│   ├── notifications/          # Compact banners and expanded cards
│   ├── clipboard/              # Clipboard response widget
│   └── launcher/               # App launcher
├── windows/                    # Top-level window / surface definitions
│   ├── BarWindow.qml           # Top menu bar panel
│   ├── NotchWindow.qml         # Dynamic island overlay
│   └── LauncherWindow.qml      # App launcher surface
└── services/                   # Background polling and data providers
```

---

## License

MIT License.
