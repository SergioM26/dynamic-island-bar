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
        └── Views/
            ├── IdleView.qml
            └── VolumeView.qml
```

- `shell.qml`: Quickshell entry point.
- `Island.qml`: creates one panel window per screen and connects the island components.
- `IslandSurface.qml`: coordinates size animations, hover state, battery color, and view transitions.
- `Controllers/`: owns the active view, expansion state, target size, and state timers.
- `Views/`: defines the content displayed for each island state.
- `Components/`: contains reusable visual elements such as the island shape, clock, date, and volume slider.
- `Services/`: provides shared system data through `TimeService` and `VolumeService`.
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

### Features
- Battery status is reflected through the island border.

---
## TODO
- [ ] Slider component for Volume And Bright control 
- [ ] Bright Control 
- [ ] idle + Hovered add a Workspace Selector
- [ ] idle + hovered show battery percentage, wifi 
- [ ] Calendar 


