# DIBAR architecture

This document describes how DIBAR is organized and how its views coordinate.
The main [README](../README.md) remains focused on features and usage.

## Project structure

```text
shell.qml
└── Island.qml
    ├── Controllers/IslandController.qml
    └── IslandSurface.qml
        ├── Components/
        ├── Controls/
        └── Views/
```

- `shell.qml` is the Quickshell entry point.
- `Island.qml` creates one panel window per screen, owns the modal background,
  and connects services to the correct monitor.
- `IslandSurface.qml` renders the island and loads the active content.
- `Controllers/IslandController.qml` owns view priority, target dimensions,
  transient timers, and transition sequencing.
- `Config/Theme.qml` centralizes geometry, typography, colors, and durations.
- `Config/Settings.qml` contains user-facing behavioral preferences such as
  optional workspace feedback and system-control limits.
- `Components/` contains low-level reusable visual primitives.
- `Controls/` combines primitives into reusable interactive controls.
- `Views/` contains the content for each island state.
- `Services/` owns system integration and shared state.

## State model

The island is state driven:

```text
System event or user input
           ↓
        Service
           ↓
   IslandController
           ↓
Shape, size, and active Loader
```

Volume, brightness, and workspace feedback are transient. The most recent
event replaces the previous transient state and restarts its display timer.

PolicyKit, the application launcher, clipboard history, the session menu, and
power profiles are modal. Modal states acquire keyboard focus, dim every
screen, and take priority over transient feedback.

## Morphing sequence

Large state changes use three phases so content does not stretch with the
surface:

```text
Current content fades out
          ↓
The empty island morphs
          ↓
New content fades in
```

Closing performs the same sequence in reverse. The controller owns the timers;
views only expose their content and interactions.

## Surface and loaders

`IslandSurface.qml` keeps one loader for every view. Opacity determines which
content is visible, while `IslandController.targetSize` drives the animated
width and height. Keeping shape state in the controller prevents individual
views from controlling the panel geometry independently.

`IslandForm.qml` draws the black surface, battery border, radius, and shadow.
Large rectangular states use a fixed maximum radius; compact states use half
their height to remain pill shaped.

## Services

Notable services include:

- `VolumeService.qml`: reactive PipeWire volume and mute state.
- `BrightnessService.qml`: selects `brightnessctl` or `ddcutil` from the
  focused Hyprland monitor. DDC writes are delayed to avoid flooding a display
  while dragging the slider.
- `WorkspaceService.qml`: reports focused-workspace changes and their monitor.
- `PolkitService.qml`: implements the graphical authentication agent.
- `AppLauncherService.qml`: controls launcher visibility and desktop-entry
  execution.
- `ClipboardService.qml`: reads `cliphist`, restores entries through
  `wl-copy`, and decodes visible image thumbnails into Quickshell's cache.
- `PowerMenuService.qml`: delays destructive session actions until their
  confirmation animation has closed.
- `PowerProfileMenuService.qml`: uses Quickshell's native UPower service rather
  than parsing `powerprofilesctl` output.
- `FocusService.qml`: releases keyboard focus held by modal layer-shell views.

## Focus restoration

The island's panel remains mapped permanently, unlike standalone launchers
such as Wofi. Merely asking Hyprland to focus the previous window can leave the
layer-shell surface holding the real keyboard focus, which appears as a hollow
cursor in terminal applications.

Before a modal opens, `FocusService.qml` stores its host monitor. After the
closing animation it briefly lowers only that panel from the top layer to the
bottom layer. This releases layer-shell keyboard focus without removing the
panel's exclusive zone, so tiled windows do not move. Hyprland then naturally
returns keyboard focus according to its normal focus policy, without forcing a
window or moving the pointer.

Session actions that replace the current interaction, such as locking,
suspending, restarting, or powering off, discard the saved focus instead.

## Multi-monitor behavior

`Island.qml` creates one panel for every `Quickshell.screens` entry. Services
record the focused monitor when opening a modal, and only the matching
controller becomes its host. The scrim appears on every monitor, but content
and exclusive keyboard focus remain on the host.

Brightness also uses monitor context: internal displays are mapped to
`brightnessctl`, while discovered external DDC/CI displays are addressed by
their I²C bus. Workspace feedback is shown on the monitor affected by the
workspace event.

## Option strips

The session and power-profile menus share
`Controls/AnimatedOptionStrip.qml`. It provides mouse selection, arrow and Tab
navigation, labels, and the centered confirmation sequence. Services execute
the selected action only after the visual closing transition completes.

