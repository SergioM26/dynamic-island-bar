# Setup and system integration

This guide covers the system services used by DIBAR. For features and common
bindings, see the main [README](../README.md).

## Dependencies

DIBAR expects:

- Quickshell 0.3 or newer with PipeWire, UPower, Hyprland, Wayland, and
  PolicyKit modules.
- PipeWire for volume control.
- `brightnessctl` for internal display brightness.
- `ddcutil` for external DDC/CI displays.
- `power-profiles-daemon` for power modes.
- `cliphist` and `wl-clipboard` for clipboard history.
- A running PolicyKit daemon.
- Ghostty for terminal desktop entries.

Package names and service setup vary by distribution.

## Starting DIBAR

Run the configuration directly while developing:

```bash
qs -p ~/.config/quickshell/shell.qml
```

Use your normal Hyprland startup configuration when you want DIBAR to start
with the session.

## PolicyKit

DIBAR is a graphical PolicyKit authentication agent; it does not replace the
system PolicyKit daemon. Only one graphical agent can be registered for a user
session.

Stop or remove the autostart entry for an existing agent such as
`hyprpolkitagent`. A basic manual check is:

```bash
systemctl --user stop hyprpolkitagent
pkexec true
```

The authentication prompt should appear inside the island. Password retries,
errors, cancellation, multi-monitor dimming, and focus restoration are handled
by DIBAR.

## Clipboard recording

`ClipboardService.qml` reads an existing `cliphist` database; it does not
record clipboard changes itself. Start one watcher for text and one for images:

```bash
wl-paste --type text --watch cliphist store
wl-paste --type image --watch cliphist store
```

Do not start duplicate watchers from multiple Hyprland configuration files.
The clipboard view decodes thumbnails only for visible image rows and stores
them in Quickshell's cache.

## Brightness

Internal displays use `brightnessctl`. Confirm that it detects a backlight
device and that the user has permission to change it.

External monitors use DDC/CI through `ddcutil`. Enable DDC/CI in the monitor's
on-screen settings, then verify discovery with:

```bash
ddcutil detect
```

The focused Hyprland monitor determines which backend receives a brightness
change. DDC displays are cached by I²C bus, and writes are delayed while
dragging to avoid excessive monitor communication.

## Power profiles

The power-profile view uses Quickshell's UPower integration and expects
`power-profiles-daemon` to be available. Performance mode is displayed only
when the system reports support for it.

## IPC and bindings

Inspect the registered commands with:

```bash
qs ipc show
```

Common targets are:

```text
appLauncher
clipboard
powerMenu
powerProfiles
brightness
```

The recommended Hyprland bindings are kept in the main
[README](../README.md).

## Troubleshooting

### PolicyKit reports that an agent already exists

Another graphical authentication agent is still running. Stop it and remove
its session autostart entry before restarting DIBAR.

### Clipboard history is empty

Confirm that the `wl-paste --watch cliphist store` processes are running and
that `cliphist list` returns entries.

### External brightness does not change

Run `ddcutil detect`, check that DDC/CI is enabled on the monitor, and verify
access to its I²C device.

### A terminal application does not launch

Desktop entries with `Terminal=true` currently open through Ghostty. Adjust
`terminalCommand` in `Services/AppLauncherService.qml` if another terminal is
preferred.

