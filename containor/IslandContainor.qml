import QtQuick
import Quickshell
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import "../widgets"

Item {
    id: root

    // This allows you to drop any widget inside the container in shell.qml
    default property alias content: container.data
    property real maxIslandWidth: 100
    implicitWidth: baseWidth + 40
    implicitHeight: baseHeight + 10

    property real baseWidth: contentLoader.item ? contentLoader.item.width : 0
    property real baseHeight: contentLoader.item ? contentLoader.item.height : 0

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutBack
            easing.overshoot: 1.9
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutBack
            easing.overshoot: 1.9
        }
    }
    property int currentIndex: 0
    property var widgets: []
    FolderListModel {
        id: widgetScanner
        folder: Qt.resolvedUrl("../widgets")
        nameFilters: ["*.qml"]
        showDirs: false

        // Triggers when the folder scanner finishes loading
        onStatusChanged: {
            if (status === FolderListModel.Ready) {
                let tempWidgets = [];
                let defaultIndex = 0; // Fallback to index 0 if not found

                for (let i = 0; i < count; i++) {
                    let url = get(i, "fileUrl");
                    if (url) {
                        tempWidgets.push(url);

                        // Check if the file is the default widget
                        let fileName = get(i, "fileName");
                        if (fileName === "Clock.qml") {
                            defaultIndex = i;
                        }
                    }
                }

                root.widgets = tempWidgets;
                root.currentIndex = defaultIndex; // Set default widget index
                console.log("Scanned widgets automatically. Default is at index:", defaultIndex);
            }
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        clip: true
        color: '#000000'
        border.color: "#3b4252"
        border.width: 0
        radius: 14

        Item {
            id: container
            height: contentLoader.item.height
            width: contentLoader.item.width
            anchors.centerIn: parent
            Loader {
                id: contentLoader
                asynchronous: false
                source: root.widgets.length > 0 ? root.widgets[root.currentIndex] : ""
                anchors.centerIn: parent
                opacity: status === Loader.Ready ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 2300
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
}
