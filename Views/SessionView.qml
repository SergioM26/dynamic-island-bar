import QtQuick
import "../Controls"
import "../Services"

AnimatedOptionStrip {
    id: root

    options: [
        { name: "Lock", confirmationLabel: "Locking…", action: "lock", iconSize: 26,
          icon: Qt.resolvedUrl("../Assets/Icons/lucide/lock.svg") },
        { name: "Suspend", confirmationLabel: "Suspending…", action: "suspend", iconSize: 26,
          icon: Qt.resolvedUrl("../Assets/Icons/lucide/circle-pause.svg") },
        { name: "Restart", confirmationLabel: "Restarting…", action: "reboot", iconSize: 28,
          icon: Qt.resolvedUrl("../Assets/Icons/lucide/rotate-ccw.svg") },
        { name: "Power off", confirmationLabel: "Shutting down…", action: "poweroff", iconSize: 27,
          icon: Qt.resolvedUrl("../Assets/Icons/lucide/power.svg") }
    ]

    confirming: PowerMenuService.confirming
    onConfirmationStarted: PowerMenuService.beginConfirmation()
    onActivated: index => PowerMenuService.commit(options[index].action)
    onCancelRequested: PowerMenuService.closeMenu()

    Connections {
        target: PowerMenuService

        function onVisibleChanged() {
            if (!PowerMenuService.visible)
                return

            root.selectedIndex = 0
            Qt.callLater(root.forceActiveFocus)
        }
    }
}
