pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
import Qt.labs.folderlistmodel

Rectangle {
    id: root
    width: 800
    height: 160
    color: "transparent"
    FolderListModel {
        id: wallpapers
        folder: "file:///home/yaz/Pictures/Wallpapers"
        nameFilters: ["*.jpg", "*.png", "*.jpeg", "*.webp"]
        showDirs: false
    }
    ListView {
        id: row
        model: wallpapers
        orientation: ListView.Horizontal
        spacing: 10
        anchors.fill: root
        cacheBuffer: 600

        delegate: Item {
            id: listItem
            required property string fileUrl
            required property string filePath
            required property int index

            width: 150
            height: 150
            anchors.verticalCenter: parent.verticalCenter
            readonly property real visibleAmount: {
                let start = row.contentX;
                let end = row.contentX + row.width;
                let imageStart = x;
                let imageEnd = x + width;
                if (imageStart > start && imageEnd > end) {
                    return imageStart - end; // returns negative
                }
                if (imageStart < start && imageStart < end) {
                    return imageEnd - start;
                }
                return width; // we use to default to avoid weirdness
            }
            Item {
                height: parent.height
                width: Math.abs(listItem.visibleAmount)
                x: listItem.visibleAmount > 0 ? listItem.width - listItem.visibleAmount : 0

                ClippingRectangle {
                    anchors.fill: parent
                    radius: 12
                    Image {
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        source: listItem.fileUrl
                        cache: true
                        sourceSize.width: 150
                        sourceSize.height: 150
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        console.log(ListView.isCurrentItem, listItem.filePath);
                        Quickshell.execDetached(["/home/yaz/.config/quickshell/scripts/wallpaper.sh", listItem.filePath]);
                    }
                }
            }
        }
    }
}
