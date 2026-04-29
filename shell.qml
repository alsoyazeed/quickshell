// qmllint disable uncreatable-type
// qmllint disable unused-imports
// qmllint disable unqualified
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "./containor"
import "./widgets"

ShellRoot {
    PanelWindow {
        id: root
        implicitHeight: 40
        HoverHandler {
            id: hoverHand
        }
        anchors {
            top: true
            right: true
            left: true
            bottom: true
        }
        margins {
            top: 20
        }
        color: 'transparent'

        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0

        mask: Region {
            item: content
        }
        IpcHandler {
            id: ipc
            target: "ui"
            function toggleIsland() {
                content.visible = !content.visible;
            }
        }
        IslandContainor {
            id: content
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            Workspace {
                anchors.centerIn: parent
            }
        }
    }
}
