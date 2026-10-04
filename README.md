# DIBAR 
---
**A Dynamic Island Bar built with Quickshell.**
*Inspired by **@saneAspect** and **@Gakuseei**.*

**DIBAR** morphs between different states depending on user interaction and system events.
The goal is to provide quick access to desktop controls using either mouse or keyboard.

---

## Architecture

```text
shell.qml
└── Island.qml
    ├── Controllers/IslandController.qml
    └── IslandSurface.qml
        ├── Components/IslandForm.qml
        ├── Controls/
        │   ├── VolumeControl.qml
        │   └── BrightnessControl.qml
        └── Views/
            ├── IdleView.qml
            ├── VolumeView.qml
            └── BrightnessView.qml
```

- `shell.qml`: Quickshell entry point.
- `Island.qml`: creates one panel window per screen and connects the island components.
- `IslandSurface.qml`: coordinates size animations, hover state, battery color, and view transitions.
- `Controllers/`: owns the active view, expansion state, target size, and state timers.
- `Views/`: defines the content displayed for each island state.
- `Components/`: contains reusable visual primitives such as the island shape, slider, and colorized icon.
- `Controls/`: adapts generic components to system features such as volume and brightness.
- `Services/`: provides shared system data through `TimeService`, `VolumeService`, and `BrightnessService`.
- `Config/Theme.qml`: centralizes sizes, colors, typography, and animation durations.

The UI follows a state-driven flow:

```text
System event or user interaction
              ↓
          Controller
              ↓
    Surface size and active view
              ↓
      Views and components
```

---

## Philosophy

- Minimalistic
- State-driven
- Keyboard and mouse parity
- Common desktop controls one interaction away
---
## Current State
### States 

| State | Components| Image |
| -------------- | --------------- | ---------------- |
|idle | Clock| ![idle](./Screenshots/idle.png) |
| idle + hovered| Clock + Date| ![idleHovered](./Screenshots/idleHovered.png) |
| Volume Control | Volume Slider| ![volume](./Screenshots/volume.png) |
| Brightness Control | Brightness Slider | — |

### Features
- Battery status is reflected through the island border.

---
## Third-party assets

Volume icons are provided by [Lucide](https://lucide.dev/) under the ISC License.
The corresponding license is included in `Assets/Icons/lucide/LICENSE`.

---
## TODO
- [X] Slider component for Volume And Bright control 
- [x] Bright Control for laptop display
- [ ] idle + Hovered add a Workspace Selector
- [ ] idle + hovered show battery percentage, wifi 
- [ ] Calendar 
