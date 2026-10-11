import QtQuick
import Quickshell
import Quickshell.Io
import "../Components"
import "../Config"
import "../Services"

FocusScope {
    id: root

    required property bool host
    property int selectedIndex: 0
    property string query: searchInput.text.trim().toLowerCase()
    readonly property var results: {
        const needle = root.query
        if (needle.length === 0)
            return ClipboardService.entries

        return ClipboardService.entries.filter(entry =>
            entry.display.toLowerCase().includes(needle))
    }

    function selectOffset(offset: int): void {
        if (results.length === 0)
            return

        selectedIndex = (selectedIndex + offset + results.length) % results.length
        resultsList.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    function copySelected(): void {
        if (results.length > 0)
            ClipboardService.copy(results[selectedIndex])
    }

    function removeSelected(): void {
        if (results.length > 0)
            ClipboardService.remove(results[selectedIndex])
    }

    function reset(): void {
        searchInput.text = ""
        selectedIndex = 0
        updateResultCount()
        resultsList.positionViewAtBeginning()
        Qt.callLater(searchInput.forceActiveFocus)
    }

    function updateResultCount(): void {
        if (host && ClipboardService.visible)
            ClipboardService.resultCount = results.length
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
            Keys.onEscapePressed: event => { ClipboardService.close(); event.accepted = true }
            Keys.onDownPressed: event => { root.selectOffset(1); event.accepted = true }
            Keys.onUpPressed: event => { root.selectOffset(-1); event.accepted = true }
            Keys.onTabPressed: event => { root.selectOffset(1); event.accepted = true }
            Keys.onBacktabPressed: event => { root.selectOffset(-1); event.accepted = true }
            Keys.onReturnPressed: event => { root.copySelected(); event.accepted = true }
            Keys.onEnterPressed: event => { root.copySelected(); event.accepted = true }
            Keys.onDeletePressed: event => { root.removeSelected(); event.accepted = true }

            Text {
                anchors.fill: parent
                text: "Search clipboard"
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
            text: root.query.length > 0
                ? root.results.length + " matches"
                : ClipboardService.entries.length + " items"
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
            height: Theme.launcherSeparatorHeight
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
            property string thumbnailSource: ""
            readonly property string thumbnailDirectory:
                Quickshell.cacheDir + "/clipboard-thumbnails"
            readonly property string thumbnailPath:
                thumbnailDirectory + "/" + modelData.id + ".png"

            width: resultsList.width - (scrollbar.visible ? Theme.launcherScrollbarSpacing : 0)
            height: Theme.launcherRowHeight
            radius: Theme.launcherRowRadius
            color: root.selectedIndex === index ? Theme.buttonColor : "transparent"

            Item {
                id: entryPreview
                anchors.left: parent.left
                anchors.leftMargin: Theme.launcherRowHorizontalPadding
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.clipboardPreviewSize
                height: Theme.clipboardPreviewSize

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.launcherIconRadius
                    color: Theme.buttonHoverColor
                    visible: !row.modelData.binary

                    Text {
                        anchors.centerIn: parent
                        text: "TXT"
                        color: Theme.secondaryTextColor
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.clipboardBadgeFontSize
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.launcherIconRadius
                    color: Theme.buttonHoverColor
                    border.width: Theme.thumbnailBorderWidth
                    border.color: Theme.thumbnailBorderColor
                    clip: true
                    visible: row.modelData.binary

                    Image {
                        anchors.fill: parent
                        source: row.thumbnailSource
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        cache: false
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "IMG"
                        color: Theme.secondaryTextColor
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.clipboardBadgeFontSize
                        visible: row.thumbnailSource.length === 0
                    }
                }
            }

            Text {
                anchors.left: entryPreview.right
                anchors.leftMargin: Theme.launcherRowContentSpacing
                anchors.right: parent.right
                anchors.rightMargin: Theme.launcherRowHorizontalPadding
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.display
                color: row.modelData.binary
                    ? Theme.secondaryTextColor
                    : Theme.foregroundColor
                font.family: Theme.fontFamily
                font.pixelSize: Theme.launcherRowFontSize
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
                    root.copySelected()
                }
            }

            Process {
                id: thumbnailProcess

                onExited: (exitCode, exitStatus) => {
                    if (exitCode === 0)
                        row.thumbnailSource = "file://" + row.thumbnailPath
                            + "?entry=" + row.modelData.id
                }
            }

            Component.onCompleted: {
                if (row.modelData.binary) {
                    thumbnailProcess.exec([
                        "sh", "-c",
                        "mkdir -p \"$1\" && if [ ! -f \"$2\" ]; then cliphist decode \"$3\" > \"$2\"; fi",
                        "cliphist-thumbnail", row.thumbnailDirectory,
                        row.thumbnailPath, row.modelData.id
                    ])
                }
            }

            Behavior on color {
                ColorAnimation { duration: Theme.contentTransitionDuration }
            }
        }

        Text {
            anchors.centerIn: parent
            text: ClipboardService.loading
                ? "Loading clipboard…"
                : "No clipboard entries found"
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
        target: ClipboardService

        function onVisibleChanged() {
            if (ClipboardService.visible && root.host)
                root.reset()
        }
    }
}
