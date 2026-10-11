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
- A terminal emulator for terminal desktop entries. Ghostty is the default.

Package names and service setup vary by distribution.

## User settings

Behavioral preferences live in `Config/Settings.qml`, separately from visual
values in `Config/Theme.qml`:

```qml
readonly property bool enableApplicationLauncher: true
readonly property bool enableClipboard: true
readonly property bool enablePowerMenu: true
readonly property bool enablePowerProfiles: true
readonly property bool enablePolkit: true
readonly property bool enableExternalBrightness: true

readonly property bool enableVolumeFeedback: true
readonly property bool enableBrightnessFeedback: true
readonly property bool enableWorkspaceFeedback: false

readonly property string internalMonitorName: "eDP-1"
readonly property real uiScale: 1.0
readonly property var terminalCommand: ["ghostty", "-e"]
readonly property real maximumVolume: 1.5
readonly property real brightnessStep: 0.05
```

The first group enables complete features. A disabled IPC feature remains a
registered target but its actions become no-ops, so existing bindings do not
need to be removed. Disabling PolicyKit prevents DIBAR from registering its
authentication agent, and disabling external brightness prevents `ddcutil`
discovery and writes.

The feedback group controls only transient island views. For example, keep
workspace handling active without displaying its number in the island:

```qml
readonly property bool enableWorkspaceFeedback: false
```

Set `internalMonitorName` to the Hyprland name of the laptop display. You can
find it with `hyprctl monitors`; external displays continue to be discovered
through `ddcutil`.

Use `uiScale` to resize DIBAR independently from the compositor. Wayland and
Qt already account for the monitor scale configured in Hyprland, so this value
is a personal size adjustment rather than the monitor's scale factor. For
example, `0.9` makes the interface 10% smaller and `1.15` makes it 15% larger.
Panels are also limited to the logical space available on each monitor.

To use Kitty for terminal desktop entries:

```qml
readonly property var terminalCommand: ["kitty", "-e"]
```

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

Desktop entries with `Terminal=true` use `terminalCommand` from
`Config/Settings.qml`. Confirm that the configured executable and its execute
argument are correct for the selected terminal.

