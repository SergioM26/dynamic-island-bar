# DIBAR

**A Dynamic Island Bar built with Quickshell.**

Inspired by **@saneAspect** and **@Gakuseei**.

DIBAR morphs between compact views in response to user interaction and system
events. It currently provides a clock, volume and display brightness controls,
battery feedback, an integrated PolicyKit authentication agent, and a session
power menu.

## Requirements

- Quickshell 0.3 or newer with the PipeWire, UPower, Hyprland, Wayland, and
  PolicyKit modules.
- PipeWire for volume control.
- `brightnessctl` for laptop display brightness.
- A PolicyKit daemon. DIBAR replaces the graphical authentication agent, not
  the PolicyKit daemon itself.

Run the shell with:

```bash
qs -p ~/.config/quickshell/shell.qml
```

## Architecture

```text
shell.qml
└── Island.qml
    ├── Controllers/IslandController.qml
    └── IslandSurface.qml
        ├── Components/IslandForm.qml
        ├── Controls/
        │   ├── ActionButton.qml
        │   ├── VolumeControl.qml
        │   └── BrightnessControl.qml
        └── Views/
            ├── IdleView.qml
            ├── VolumeView.qml
            ├── BrightnessView.qml
            ├── AuthenticationView.qml
            └── SessionView.qml
```

- `shell.qml`: Quickshell entry point.
- `Island.qml`: creates one panel window per screen and connects the island components.
- `IslandSurface.qml`: renders the island shape and coordinates content loaders.
- `Controllers/`: owns the active view, target size, expansion state, and transition timing.
- `Views/`: defines the content displayed for each island state.
- `Components/`: contains reusable visual primitives such as the island shape, slider, and colorized icon.
- `Controls/`: composes reusable components into volume, brightness, and action controls.
- `Services/`: provides shared system data and actions through time, volume,
  brightness, PolicyKit, and power-menu services.
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

## PolicyKit authentication

`PolkitService.qml` registers DIBAR as the desktop authentication agent. A
request is shown on the monitor that was focused when it arrived. While the
dialog is active, the island moves to the overlay layer and acquires exclusive
keyboard focus. Password submission, cancellation, retries, and authentication
errors are handled through Quickshell's PolicyKit service.

Only one PolicyKit authentication agent can be registered for a user session.
Stop or remove the autostart entry for agents such as `hyprpolkitagent` before
starting DIBAR. A quick manual test is:

```bash
systemctl --user stop hyprpolkitagent
pkexec true
```

The authentication transition is intentionally sequential:

```text
Current content fades out
          ↓
The empty island morphs
          ↓
Authentication content fades in
```

The sequence is reversed after success or cancellation.

## Session menu

`PowerMenuService.qml` exposes the session menu through Quickshell IPC and
executes its lock, suspend, restart, and power-off actions. The menu opens on
the currently focused monitor:

```bash
qs ipc call powerMenu toggle
qs ipc call powerMenu open
qs ipc call powerMenu close
```

An example Hyprland binding is:

```lua
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("qs ipc call powerMenu toggle"))
```

`SessionView.qml` supports mouse hover and click as well as keyboard navigation:

- `Left` / `Right`: change the selected action.
- `Enter` / `Space`: execute the selected action.
- `Escape`: close the menu.

The selected indicator moves with a spring animation and a subtle squash
effect. Opening the menu dims and blocks every screen while keeping the menu
and keyboard focus on the monitor that was active when it opened. PolicyKit
uses the same multi-monitor modal background.

## Design principles

- Minimalistic
- State-driven
- Compact pill-shaped surfaces
- White for primary content, gray for secondary content, and black for the default border
- Sequential content and shape transitions
- Common desktop controls one interaction away

## Current state

### Views

| View | Content | Preview |
| --- | --- | --- |
| Idle | Clock | ![Idle](./Screenshots/idle.png) |
| Idle + hover | Clock and date | ![Idle hovered](./Screenshots/idleHovered.png) |
| Volume | Volume slider, mute action, and percentage up to 150% | ![Volume](./Screenshots/volume.png) |
| Brightness | Laptop display brightness and percentage | — |
| Authentication | PolicyKit prompt, password input, actions, and errors | — |
| Session menu | Lock, suspend, restart, and power off | — |

The island border reflects battery status: black normally, green while
charging, yellow for a warning, and red when battery is low. Authentication
uses a borderless surface.

## Third-party assets

Interface icons are provided by [Lucide](https://lucide.dev/) under the ISC License.
The corresponding license is included in `Assets/Icons/lucide/LICENSE`.

## TODO

- [x] Reusable slider for volume and brightness
- [x] Laptop display brightness control
- [x] Integrated PolicyKit authentication agent
- [ ] Workspace selector in the expanded idle view
- [ ] Battery percentage and Wi-Fi status in the expanded idle view
- [ ] Calendar
- [ ] External monitors brightness control with ddcutil
- [ ] Reliably restore the previously focused window after closing a modal
