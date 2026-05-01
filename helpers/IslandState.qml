import QtQuick
import Quickshell.Io
import "../containor"

Item {
    IpcHandler {
        id: ipc
        target: "ui"
        function toggleIsland() {
            container.enabled = !container.enabled;
            container.visible = !container.visible;
        }
        function cycleIsland() {
            container.currentIndex = (container.currentIndex + 1) % container.widgets.length;
        }
    }
    property var widgets: container
    IslandContainor {
        id: container
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
