import QtQuick 2.15
import "../../theme"
import "../../services"
import "../../services/popover"

// FileCard — SoftShell File Dropdown Card
// Layout: Recent 5 Downloads -> Bookmarks -> Trash
Rectangle {
    id: root

    property FileService fileService: null

    implicitWidth: 320
    implicitHeight: mainCol.implicitHeight + 20

    radius: Theme.popoverRadius
    color: Theme.popoverBg
    border.color: Theme.popoverBorder
    border.width: 1
    antialiasing: true

    Column {
        id: mainCol
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8
        spacing: 6

        // -------------------------------------------------------------------
        // 1. RECENT DOWNLOADS
        // -------------------------------------------------------------------
        Item {
            width: parent.width
            height: 20

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: "Recent Downloads"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: Theme.appleHeaderMuted
                renderType: Text.NativeRendering
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: "Open All"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
                color: openAllHover.hovered ? "#3395ff" : "#007aff"
                renderType: Text.NativeRendering

                HoverHandler {
                    id: openAllHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        if (root.fileService) root.fileService.openFolder(Quickshell.env("HOME") + "/Downloads");
                        PopoverManager.close("file");
                    }
                }
            }
        }

        Repeater {
            model: root.fileService ? root.fileService.downloads : []
            delegate: FileItemRow {
                fileData: modelData
                onOpenClicked: {
                    if (root.fileService) root.fileService.openFile(modelData.path);
                    PopoverManager.close("file");
                }
                onRevealClicked: {
                    if (root.fileService) root.fileService.revealFile(modelData.path);
                    PopoverManager.close("file");
                }
            }
        }

        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.popoverSeparator
        }

        // -------------------------------------------------------------------
        // 2. BOOKMARKS / PLACES
        // -------------------------------------------------------------------
        Item {
            width: parent.width
            height: 20

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: "Bookmarks"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: Theme.appleHeaderMuted
                renderType: Text.NativeRendering
            }
        }

        Repeater {
            model: root.fileService ? root.fileService.bookmarks : []
            delegate: FolderItemRow {
                folderData: modelData
                onClicked: {
                    if (root.fileService) root.fileService.openFolder(modelData.path);
                    PopoverManager.close("file");
                }
            }
        }

        // Divider
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.popoverSeparator
        }

        // -------------------------------------------------------------------
        // 3. TRASH
        // -------------------------------------------------------------------
        TrashRow {
            count: root.fileService ? root.fileService.trashCount : 0
            text: root.fileService ? root.fileService.trashText : "Empty"
            glyph: root.fileService ? root.fileService.trashGlyph : "󰩺"
            onClicked: {
                if (root.fileService) root.fileService.openFolder("trash:///");
                PopoverManager.close("file");
            }
            onEmptyClicked: {
                if (root.fileService) root.fileService.emptyTrash();
            }
        }
    }
}
