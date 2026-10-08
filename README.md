# DIBAR

**A Dynamic Island Bar built with Quickshell.**

Inspired by **@saneAspect** and **@Gakuseei**.

DIBAR morphs between compact views in response to user interaction and system
events. It currently provides a clock, workspace feedback, volume and display
brightness controls, power-profile selection, battery feedback, an integrated
PolicyKit authentication agent, and a session power menu.

## Requirements

- Quickshell 0.3 or newer with the PipeWire, UPower, Hyprland, Wayland, and
  PolicyKit modules.
- PipeWire for volume control.
- `brightnessctl` for laptop display brightness.
- `ddcutil` for external monitor brightness through DDC/CI.
- `power-profiles-daemon` for system power-profile control.
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
        │   ├── AnimatedOptionStrip.qml
        │   ├── VolumeControl.qml
        │   └── BrightnessControl.qml
        └── Views/
            ├── IdleView.qml
            ├── WorkspaceView.qml
            ├── VolumeView.qml
            ├── BrightnessView.qml
            ├── AuthenticationView.qml
            ├── SessionView.qml
            └── PowerProfileView.qml
```

- `shell.qml`: Quickshell entry point.
- `Island.qml`: creates one panel window per screen and connects the island components.
- `IslandSurface.qml`: renders the island shape and coordinates content loaders.
- `Controllers/`: owns the active view, target size, expansion state, and transition timing.
- `Views/`: defines the content displayed for each island state.
- `Components/`: contains reusable visual primitives such as the island shape, slider, and colorized icon.
- `Controls/`: composes reusable components into volume, brightness, and action controls.
- `Services/`: provides shared system data and actions through time, workspace,
  volume, brightness, power profiles, PolicyKit, and power-menu services.
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

## Workspace indicator

`WorkspaceService.qml` observes Hyprland's focused workspace. When it changes,
the clock fades out, the island contracts into a circle, and the workspace
number is shown briefly on the affected monitor before returning to `Idle`.

Authentication, the session menu, and the power-profile menu are modal and
therefore take priority.
Workspace, volume, and brightness are transient views: the most recent system
event replaces the previous transient view and restarts its display timer.

## Contextual brightness

`BrightnessService.qml` chooses the brightness backend from Hyprland's focused
monitor. Internal laptop displays use `brightnessctl`; external DDC/CI displays
use `ddcutil`. DDC displays are discovered at startup and then addressed by
their resolved I²C bus to avoid repeatedly scanning every connector.

The service exposes IPC commands intended for compositor keybindings:

```bash
qs ipc call brightness increase
qs ipc call brightness decrease
```

For example:

```lua
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("qs ipc call brightness increase"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("qs ipc call brightness decrease"), { locked = true, repeating = true })
```

The brightness island appears only on the focused display. Laptop writes are
debounced for responsiveness, while DDC writes use a longer delay and skip
write verification to avoid flooding the monitor during slider movement.

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
- `Tab` / `Shift+Tab`: move forward or backward through the actions.
- `Enter` / `Space`: execute the selected action.
- `Escape`: close the menu.

The active option name is shown below the icons. The selected indicator moves
with a spring animation and a subtle squash effect. After activation, the
other options and selection background fade out while the selected icon moves
to the center above a progress label such as `Locking…` or `Shutting down…`.
The island then contracts into a compact pill, pauses briefly in that
confirmation state, and closes before executing the action. Opening the menu
dims and blocks every screen while keeping the menu and keyboard focus on the
monitor that was active when it opened. PolicyKit uses the same multi-monitor
modal background.

## Power profiles

`PowerProfileMenuService.qml` uses Quickshell's native `PowerProfiles` service
to read and change the active mode reactively. It does not execute or parse
`powerprofilesctl`. Open the selector with:

```bash
qs ipc call powerProfiles toggle
```

The menu offers power saver, balanced, and performance when supported by the
system. It shares `AnimatedOptionStrip.qml` with the session menu, including
mouse selection, arrow-key navigation, Enter/Space activation, Escape to
close, the selected-option label, and the centered confirmation animation. It
opens modally on the focused monitor and applies the profile only after the
menu has completed its closing transition.

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
| Workspace | Active workspace number on the affected monitor | — |
| Volume | Volume slider, mute action, and percentage up to 150% | ![Volume](./Screenshots/volume.png) |
| Brightness | Contextual laptop or external-monitor brightness and percentage | — |
| Authentication | PolicyKit prompt, password input, actions, and errors | — |
| Session menu | Lock, suspend, restart, and power off, in safe-first order | — |
| Power profiles | Power saver, balanced, and performance selector | — |

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
- [x] External monitor brightness control with ddcutil
- [ ] Reliably restore the previously focused window after closing a modal
