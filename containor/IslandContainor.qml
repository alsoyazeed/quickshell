import QtQuick
import Quickshell
import QtQuick.Layouts

Item {
    id: root

    // This allows you to drop any widget inside the container in shell.qml
    default property alias content: container.data

    implicitWidth: Math.min(450, Math.max(cWidth + padding * 2, xS))
    implicitHeight: Math.min(250, Math.max(cHeight + padding * 2, yS))
    readonly property int cWidth: container.childrenRect.width
    readonly property int cHeight: container.childrenRect.height
    readonly property int xS: dragHand.centroid.position.x
    property int yS: dragHand.centroid.position.y
    property int padding: 15
    property int radius: 16
    property int animationDuration: 350

    width: implicitWidth
    height: implicitHeight

    Behavior on width {
        SpringAnimation {
            spring: 2
            damping: 0.2
        }
    }
    Behavior on height {
        SpringAnimation {
            spring: 2
            damping: 0.2
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter

        color: "#1a1b26"
        border.color: "#3b4252"
        border.width: 1
        radius: root.radius
        clip: true
        DragHandler {
            id: dragHand
        }

        Item {
            id: container
            Layout.alignment: Qt.AlignCenter
            anchors.centerIn: parent
        }
    }
}
