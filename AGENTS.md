# AGENTS.md - Quickshell & QML Shell Development Guidelines

This document provides instructions, architectural rules, and coding standards for developing desktop shells, widgets, and overlays using **Quickshell** and **QML**.

DONT FUCKING FORGET TO UPDATE THE INSTALL SCRIPT WHEN NECESSARY
DONT MENTION MACOS INSTEAD MENTION SOFTSHELL THOUGH IT IS INSPIRED FROM MACOS
---

## 1. Core Mandate: Component Decomposition & Modularization

> **CRITICAL RULE**: **Never write monolithic QML files.**
> All shell features, widgets, windows, and services must be broken down into small, single-responsibility, and reusable components.

### 1.1 Structural Organization

Maintain a clean and predictable directory structure:

```
├── shell.qml                   # Main entrypoint: loads panels and screens
├── theme/                      # Styling tokens, colors, typography, metrics
│   ├── Theme.qml               # Singleton for global style tokens
│   └── qmldir                  # Module definition for singletons
├── components/                 # Reusable generic UI primitives
│   ├── StyledButton.qml        # Custom button component
│   ├── SmoothSlider.qml        # Custom slider with animations
│   ├── IslandShape.qml         # Shaped backgrounds/masks
│   └── IconLabel.qml           # Combined icon + text helper
├── widgets/                    # Domain-specific shell widgets
│   ├── clock/                  # Time/calendar widget
│   │   ├── ClockWidget.qml
│   │   └── CalendarPopup.qml
│   ├── battery/                # Battery status & popover
│   ├── network/                # Network status & popover
│   ├── workspaces/             # Compositor workspace switcher
│   ├── mpris/                  # Media player controller
│   ├── audio/                  # Volume & device controls
│   └── system/                 # System resource monitors (CPU/RAM)
├── windows/                    # Top-level window / surface definitions
│   ├── BarWindow.qml           # Main status bar panel
│   ├── NotchWindow.qml         # Dynamic island / notch overlay
│   ├── LauncherWindow.qml      # App launcher / runner surface
│   └── OsdWindow.qml           # On-screen display (volume/brightness)
└── services/                   # Data providers, IPC, and system integration
    ├── HyprlandIpc.qml         # Compositor IPC connection/listener
    ├── AudioService.qml        # Pipewire / wpctl interface
    └── SystemStatsService.qml  # Resource & network monitoring backend
```

### 1.2 Decomposition Principles

1. **Maximum File Size Guideline**: Aim to keep QML components under **100–150 lines**. If a file grows beyond this or handles more than one visual concern, refactor sub-elements into their own files.
2. **Single Responsibility**:
   - A **Window** (`PanelWindow`, `FloatingWindow`) only manages window-level properties (layer, anchors, exclusive zone, screen, input masks).
   - A **Widget** represents a cohesive functional unit (e.g. `ClockWidget.qml`, `MediaWidget.qml`).
   - A **Component** represents a pure UI building block (e.g. `IconButton.qml`, `RoundedCard.qml`).
   - A **Service** manages state, background polling, or IPC without containing visual UI elements.
3. **Encapsulation & Interfaces**:
   - Expose explicit properties (`property type name: defaultValue`) and signals (`signal clicked()`) at the root element of each component.
   - Avoid hardcoding parent IDs or referencing external scope directly. Let parent components pass data down and listen to signals.
   - Provide fallback defaults for all properties so components render safely in isolation or preview.

---

## 2. Quickshell & Wayland Architecture

### 2.1 Window Types & Anchoring
- **`PanelWindow`**: Use for bars, docks, and dynamic notches attached to monitor edges.
  - Set `exclusiveZone` appropriately:
    - `exclusiveZone: height` (or `width`) when desktop windows should not overlap the panel.
    - `exclusiveZone: 0` for floating overlays, notifications, OSDs, or dynamic islands.
  - Set `color: "transparent"` when drawing custom shapes or rounded corners to prevent black rectangular bounding boxes.
- **Layer Shell Rules**:
  - Specify the appropriate layer (`WlrLayershell.Layer.Top`, `Overlay`, or `Bottom`).
  - Set a descriptive `WlrLayershell.namespace` (e.g., `namespace: "quickshell:bar"`) so compositor blur, shadow, and window rules can target specific surfaces.

### 2.2 Input Masking & Hit Testing
- For non-rectangular or floating components (e.g. a dynamic island or pill bar):
  - Ensure transparent areas do not steal mouse clicks from underlying client windows.
  - Configure the window's `mask` or input region to match only the interactive geometry.
- Prefer `HoverHandler` and `TapHandler` over legacy `MouseArea` where possible for modern QtQuick event handling.

### 2.3 Window Exclusivity & Single Active Popover
- **Single Active Popover Rule (`PopoverManager`)**: Opening any popover or menu from the top bar (Battery, Wi-Fi, Control Center, App Menu) must **automatically close any other open popovers**. Multiple popovers must never overlap or stay open simultaneously.
- **Tight Visual Docking**: Popover surfaces must be positioned closely to their trigger icons (within **2–4px** of the bar) to look anchored to the menu bar rather than disconnected.

### 2.4 Non-Blocking Execution
- **Never block the QML UI thread.**
- When interacting with shell commands or external tools, use Quickshell's asynchronous `Process` APIs:
  - Read output via asynchronous signals (`onStdoutChanged`, `onFinished`, `StdioCollector`, `SplitParser`).
  - Gracefully handle process errors and non-zero exit codes.
- Utilize Quickshell's built-in services (`Quickshell.Services.Pipewire`, `Quickshell.Services.Mpris`, `Quickshell.Services.SystemTray`, etc.) instead of spawning external CLI tools repeatedly.

---

## 3. Visual Aesthetics & SoftShell Design System

### 3.1 Pure AMOLED Black Overlays
- Popovers (Battery, Network, Control Center) and floating OSD indicators must use **100% opaque AMOLED Black** (`#000000` / `#161618`).
- Do not use milky translucent or frosted glass backgrounds for popovers or on-screen display indicators.
- Floating OSD indicators (volume, brightness, mic mute) should remain borderless and clean against the dark background.

### 3.2 Flat, Opaque White Glyphs
- Status bar and indicator glyphs must render as crisp, flat, opaque white (`#ffffff`).
- Avoid 3D bevels, raised styling, or blurry drop shadows (do not use `style: Text.Raised`).

### 3.3 Antialiasing Everywhere
- Explicitly enable `antialiasing: true` on all rectangles, circular badges, sliders, borders, and custom shapes to prevent jagged edges.

### 3.4 Clean Hierarchy & SoftShell Styling
- Avoid cluttered card-in-card designs (GNOME/Libadwaita style).
- Use flat sections separated by subtle dividers (`Theme.popoverSeparator`).
- Use blue link-style action text (e.g., "Disconnect", "Forget") for secondary actions.

### 3.5 Wallpaper Presentation
- Background wallpapers must always use `fillMode: Image.PreserveAspectCrop` (CSS `object-fit: cover`) to fill the entire monitor geometry without letterboxing or distortion.

---

## 4. Notifications & Dynamic Island Interactions

### 4.1 Notification Focus & Workspace Switching
- When the user clicks on a notification (or the "View" action button in the dynamic island), the shell must communicate with the compositor (Hyprland IPC) to find the window associated with the notification and **automatically switch to that workspace and focus the window**.

### 4.2 Auto-Unpin / Dismiss After Action
- Clicking any notification action button (e.g., "View" or "Dismiss") must collapse the dynamic island and **must never leave it pinned or stuck in the expanded state**.

### 4.3 Hover Suppression During Active Alerts
- When a notification is active in the collapsed/shrink dynamic island, mouse hover must not accidentally trigger compact music or pill expansion.

---

## 5. Shell & Terminal Execution

### 5.1 Respect User Login Shell (Default to Zsh)
- When launching commands, user-defined apps, or spawning terminal windows, **never default to `bash`**.
- Always check the user's active shell (`Quickshell.env("SHELL")`) or default explicitly to `zsh` (`/usr/bin/zsh`).

---

## 6. Dynamic & Reactive Hardware Status

### 6.1 No Static Status Bar Icons
- Status bar icons (Network, Battery, Volume, Microphone) must **never be static dummy glyphs**. They must react dynamically to real-time hardware status:
  - **Wi-Fi**: Connected signal tiers (`󰤨` $\ge 75\%$, `󰤥` $\ge 50\%$, `󰤢` $\ge 25\%$, `󰤟` $> 0\%$, `󰤯` $0\%$), disconnected (`󰤭`), radio disabled (`󰤮`), captive portal / limited connectivity (`󰤩`).
  - **Ethernet**: Wired connection glyph (`󰈀`).
  - **Battery**: Dynamic percentage fill, warning yellow ($<40\%$), critical red ($<20\%$), charging green (`Theme.batteryCharging`).

### 6.2 Modern Hardware Probing
- Never rely on obsolete kernel paths like `/proc/net/wireless` (modern Linux Wi-Fi drivers do not populate it).
- Use fast, non-blocking asynchronous CLI probes (`nmcli`, `upower`, `wpctl`) with lightweight polling cadences (3–4 seconds for network, 2 seconds for CPU/RAM/Battery).

### 6.3 Significant Energy Process Filtering
- Resource monitors in the power popover must not dump raw unfiltered process lists. Filter by meaningful thresholds (e.g. only processes using $>20\%$ CPU or $>30\%$ GPU) to accurately highlight power-draining apps.

---

## 7. QML Best Practices & Conventions

### 7.1 Declarative Over Imperative
- **Property Bindings**: Always prefer declarative bindings over imperative JavaScript assignments in signal handlers.
- **Avoid Binding Loops**: Do not reassign properties inside handlers that depend on those properties.
- **Strict Typing**: Always declare explicit types (`property int count`, `property real progress`, `property string label`, `property color activeColor`) instead of `property var`.

### 7.2 Component Ordering Convention
Maintain a consistent structure inside all QML files:
```qml
Item {
    id: root

    // 1. Component Public Interface (Properties & Signals)
    property string title: ""
    property bool active: false
    signal triggered()

    // 2. Geometry & Layout
    implicitWidth: 200
    implicitHeight: 40

    // 3. Internal State / Private Variables
    readonly property bool _hasContent: title.length > 0

    // 4. Signal Handlers
    onActiveChanged: { /* ... */ }

    // 5. Animations & Behaviors
    Behavior on opacity { NumberAnimation { duration: 150 } }

    // 6. Child Elements / Visual Tree
    Rectangle {
        id: background
        anchors.fill: parent
        // ...
    }

    // 7. States & Transitions
    states: [ /* ... */ ]
    transitions: [ /* ... */ ]
}
```

### 7.3 Theme & Design System
- Centralize all colors, spacing, corner radii, and font definitions in a single theme file (`theme/Theme.qml`).
- Use `pragma Singleton` with a `qmldir` file so that `Theme` is accessible across any component without manual relative path importing.

### 7.4 Smooth Transitions & Spring Animations
- Keep animations snappy and natural:
  - Use `SpringAnimation` for dynamic physical interactions (e.g. dynamic island expand/collapse, sliders).
  - Use `NumberAnimation` with `Easing.OutCubic` or `Easing.OutQuad` for general UI transitions.
  - Standard durations: 120ms to 250ms. Avoid animations longer than 350ms for frequent desktop actions.

---

## 8. Development & Verification Workflow

1. **Verify Syntax & Logs**:
   - Run `quickshell` in the terminal to inspect startup logs, QML warning messages, and unresolved import paths.
   - Watch for type warnings, binding loop notifications, or missing object errors in the stdout/stderr stream.
2. **Local Sync & Testing**:
   - Keep `~/.config/quickshell` in continuous sync (`rsync -av --exclude='.git' ./ ~/.config/quickshell/`).
   - Test changes locally and reload via IPC (`quickshell ipc ...`) or process restart.
3. **Daemon Hygiene**:
   - Ensure old or competing background daemons (e.g. `serpantinumd`, orphaned `mpvpaper`, stale `quickshell` processes) are cleaned up during installs and reloads.
4. **Git Hygiene**:
   - Avoid premature or noisy git pushes for every tiny incremental change; commit and push when features and bug fixes are complete and verified.
5. **Install Script Synchronization**:
   - Always update `install.sh` whenever new dependencies, files, or services are added to the project.
