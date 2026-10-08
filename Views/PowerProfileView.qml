import QtQuick
import Quickshell.Services.UPower
import "../Controls"
import "../Services"

AnimatedOptionStrip {
    id: root

    options: {
        const base = [
            { name: "Power saver", confirmationLabel: "Power saver ON",
              profile: PowerProfile.PowerSaver, iconSize: 25,
              icon: Qt.resolvedUrl("../Assets/Icons/lucide/leaf.svg") },
            { name: "Balanced", confirmationLabel: "Balanced ON",
              profile: PowerProfile.Balanced, iconSize: 27,
              icon: Qt.resolvedUrl("../Assets/Icons/lucide/gauge.svg") }
        ]

        if (PowerProfileMenuService.hasPerformanceProfile)
            base.push({ name: "Performance",
                        confirmationLabel: "Performance ON",
                        profile: PowerProfile.Performance,
                        iconSize: 25, icon: Qt.resolvedUrl("../Assets/Icons/lucide/zap.svg") })

        return base
    }

    function syncSelection(): void {
        for (let index = 0; index < options.length; ++index) {
            if (options[index].profile === PowerProfileMenuService.profile) {
                selectedIndex = index
                return
            }
        }
    }

    confirming: PowerProfileMenuService.confirming
    onConfirmationStarted: PowerProfileMenuService.beginConfirmation()
    onActivated: index => PowerProfileMenuService.commit(options[index].profile)
    onCancelRequested: PowerProfileMenuService.closeMenu()

    Connections {
        target: PowerProfileMenuService

        function onVisibleChanged() {
            if (!PowerProfileMenuService.visible)
                return

            root.syncSelection()
            Qt.callLater(root.forceActiveFocus)
        }

        function onProfileChanged() {
            if (PowerProfileMenuService.visible && !PowerProfileMenuService.confirming)
                root.syncSelection()
        }
    }
}
