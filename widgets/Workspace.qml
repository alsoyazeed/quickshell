// qmllint disable unqualified
import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Rectangle {
    id: root
    implicitWidth: 400

    implicitHeight: 40
    color: "transparent"
    Row {

        anchors.centerIn: parent
        spacing: 4
        Repeater {
            model: 9

            Rectangle {
                id: ws
                width: isActive ? 40 : 20
                height: 20
                scale: mArea.containsMouse ? 1.2 : 1
                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                color: isActive ? "#0db9d7" : (ws ? "#7aa2f7" : "#444b6a")
                radius: height / 2
                Behavior on scale {
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.OutExpo // Smooth, fast start, slow end
                    }
                }
                Behavior on width {
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.OutExpo // Smooth, fast start, slow end
                    }
                }
                MouseArea {
                    id: mArea
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                    hoverEnabled: true
                }
            }
        }
    }
}
