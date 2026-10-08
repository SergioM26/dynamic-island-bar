import QtQuick
import "../Config"
import "../Services"

Item {
    Text {
        anchors.centerIn: parent
        text: WorkspaceService.label
        color: Theme.foregroundColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.workspaceFontSize
        font.weight: Font.DemiBold
    }
}
