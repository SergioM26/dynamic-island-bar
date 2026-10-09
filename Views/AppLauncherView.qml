import QtQuick
import Quickshell
import "../Components"
import "../Config"
import "../Services"

FocusScope {
    id: root

    required property bool host
    property int selectedIndex: 0
    property string query: searchInput.text.trim().toLowerCase()
    readonly property var applications: DesktopEntries.applications.values
    readonly property var results: {
        const needle = root.query
        const matches = root.applications.filter(entry => {
            if (needle.length === 0)
                return true

            const searchable = [
                entry.name ?? "",
                entry.genericName ?? "",
                entry.comment ?? "",
                (entry.keywords ?? []).join(" ")
            ].join(" ").toLowerCase()

            return searchable.includes(needle)
        })

        matches.sort((left, right) => {
            const leftName = left.name.toLowerCase()
            const rightName = right.name.toLowerCase()
            const leftStarts = needle.length > 0 && leftName.startsWith(needle)
            const rightStarts = needle.length > 0 && rightName.startsWith(needle)

            if (leftStarts !== rightStarts)
                return leftStarts ? -1 : 1

            return leftName.localeCompare(rightName)
        })

        return matches
    }

    function selectOffset(offset: int): void {
        if (results.length === 0)
            return

        selectedIndex = (selectedIndex + offset + results.length) % results.length
        resultsList.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    function launchSelected(): void {
        if (results.length === 0)
            return

        const entry = results[selectedIndex]
        AppLauncherService.launch(entry)
    }

    function reset(): void {
        searchInput.text = ""
        selectedIndex = 0
        updateResultCount()
        resultsList.positionViewAtBeginning()
        Qt.callLater(searchInput.forceActiveFocus)
    }

    function updateResultCount(): void {
        if (host && AppLauncherService.visible)
            AppLauncherService.resultCount = results.length
    }

    Item {
        id: searchHeader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Theme.launcherHeaderHeight

        ColorizedIcon {
            anchors.left: parent.left
            anchors.leftMargin: Theme.launcherHorizontalPadding
            anchors.verticalCenter: searchInput.verticalCenter
            width: Theme.launcherSearchIconSize
            height: Theme.launcherSearchIconSize
            source: Qt.resolvedUrl("../Assets/Icons/lucide/search.svg")
            color: Theme.foregroundColor
        }

        TextInput {
            id: searchInput
            anchors.left: parent.left
            anchors.leftMargin: Theme.launcherHorizontalPadding
                + Theme.launcherSearchIconSize + Theme.launcherSearchSpacing
            anchors.right: counter.left
            anchors.rightMargin: Theme.launcherSearchSpacing
            y: Theme.launcherInputTop
            height: Theme.launcherInputHeight
            color: Theme.foregroundColor
            selectionColor: Theme.selectionColor
            selectedTextColor: Theme.backgroundColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.launcherInputFontSize
            verticalAlignment: TextInput.AlignVCenter
            clip: true

            Keys.priority: Keys.BeforeItem
            Keys.onEscapePressed: event => {
                AppLauncherService.close()
                event.accepted = true
            }
            Keys.onDownPressed: event => { root.selectOffset(1); event.accepted = true }
            Keys.onUpPressed: event => { root.selectOffset(-1); event.accepted = true }
            Keys.onTabPressed: event => { root.selectOffset(1); event.accepted = true }
            Keys.onBacktabPressed: event => { root.selectOffset(-1); event.accepted = true }
            Keys.onReturnPressed: event => { root.launchSelected(); event.accepted = true }
            Keys.onEnterPressed: event => { root.launchSelected(); event.accepted = true }

            Text {
                anchors.fill: parent
                text: "Search apps"
                color: Theme.secondaryTextColor
                font: searchInput.font
                verticalAlignment: Text.AlignVCenter
                visible: searchInput.text.length === 0
            }

            onTextChanged: {
                root.selectedIndex = 0
                Qt.callLater(root.updateResultCount)
                Qt.callLater(() => resultsList.positionViewAtBeginning())
            }
        }

        Text {
            id: counter
            anchors.right: parent.right
            anchors.rightMargin: Theme.launcherHorizontalPadding
            anchors.verticalCenter: searchInput.verticalCenter
            text: root.results.length + "/" + root.applications.length
            color: Theme.secondaryTextColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.launcherCounterFontSize
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.launcherHorizontalPadding
            anchors.rightMargin: Theme.launcherHorizontalPadding
            anchors.bottom: parent.bottom
            height: 1
            color: Theme.sliderTrackColor
        }
    }

    ListView {
        id: resultsList
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: searchHeader.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: Theme.launcherHorizontalPadding
        anchors.rightMargin: Theme.launcherHorizontalPadding
        anchors.topMargin: Theme.launcherListTopPadding
        anchors.bottomMargin: Theme.launcherBottomPadding
        model: root.results
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        currentIndex: root.selectedIndex

        delegate: Rectangle {
            id: row
            required property var modelData
            required property int index

            width: resultsList.width - (scrollbar.visible ? Theme.launcherScrollbarSpacing : 0)
            height: Theme.launcherRowHeight
            radius: Theme.launcherRowRadius
            color: root.selectedIndex === index
                ? Theme.buttonColor
                : "transparent"

            Image {
                id: appIcon
                anchors.left: parent.left
                anchors.leftMargin: Theme.launcherRowHorizontalPadding
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.launcherAppIconSize
                height: Theme.launcherAppIconSize
                source: modelData.icon.length > 0
                    ? Quickshell.iconPath(modelData.icon, true)
                    : ""
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            Rectangle {
                anchors.fill: appIcon
                radius: 6
                color: Theme.buttonHoverColor
                visible: appIcon.status !== Image.Ready

                Text {
                    anchors.centerIn: parent
                    text: row.modelData.name.length > 0
                        ? row.modelData.name.charAt(0).toUpperCase()
                        : "?"
                    color: Theme.foregroundColor
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.launcherFallbackIconFontSize
                }
            }

            Text {
                anchors.left: appIcon.right
                anchors.leftMargin: Theme.launcherRowContentSpacing
                anchors.right: description.left
                anchors.rightMargin: Theme.launcherRowContentSpacing
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.name
                color: Theme.foregroundColor
                font.family: Theme.fontFamily
                font.pixelSize: Theme.launcherRowFontSize
                elide: Text.ElideRight
            }

            Text {
                id: description
                anchors.right: parent.right
                anchors.rightMargin: Theme.launcherRowHorizontalPadding
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.launcherDescriptionWidth
                text: row.modelData.genericName || row.modelData.comment
                color: Theme.secondaryTextColor
                font.family: Theme.fontFamily
                font.pixelSize: Theme.launcherDescriptionFontSize
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideRight
            }

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
                onHoveredChanged: {
                    if (hovered)
                        root.selectedIndex = row.index
                }
            }

            TapHandler {
                onTapped: {
                    root.selectedIndex = row.index
                    root.launchSelected()
                }
            }

            Behavior on color {
                ColorAnimation { duration: Theme.contentTransitionDuration }
            }
        }

        Text {
            anchors.centerIn: parent
            text: "No applications found"
            color: Theme.secondaryTextColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.launcherRowFontSize
            visible: root.results.length === 0
        }

        Rectangle {
            id: scrollbar
            anchors.right: parent.right
            anchors.top: parent.top
            width: Theme.launcherScrollbarWidth
            height: parent.height
            color: "transparent"
            visible: resultsList.contentHeight > resultsList.height

            Rectangle {
                anchors.right: parent.right
                y: resultsList.contentHeight <= resultsList.height
                    ? 0
                    : resultsList.contentY
                        / (resultsList.contentHeight - resultsList.height)
                        * (parent.height - height)
                width: parent.width
                height: Math.max(
                    Theme.launcherScrollbarMinHeight,
                    parent.height * parent.height / resultsList.contentHeight
                )
                radius: width / 2
                color: Theme.secondaryTextColor
            }
        }
    }

    onResultsChanged: {
        if (selectedIndex >= results.length)
            selectedIndex = Math.max(0, results.length - 1)
        updateResultCount()
    }

    Connections {
        target: AppLauncherService

        function onVisibleChanged() {
            if (AppLauncherService.visible && root.host)
                root.reset()
        }
    }
}
