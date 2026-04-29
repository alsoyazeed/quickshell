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
    readonly property real resistance: 0.8 // Lower = heavier/more resistance
    property int padding: 15
    property int radius: 16
    readonly property int xS: {
        let delta = dragHand.centroid.position.x - (cWidth / 2);
        return cWidth + (delta * resistance);
    }

    readonly property int yS: {
        let delta = dragHand.centroid.position.y - (cHeight / 2);
        return cHeight + (delta * resistance);
    }

    width: implicitWidth
    height: implicitHeight

    Behavior on width {
        SpringAnimation {
            spring: 5      // Higher tension
            damping: 0.7    // More friction/weight
            epsilon: 0.1
        }
    }
    Behavior on height {
        SpringAnimation {
            spring: 5      // Higher tension
            damping: 0.7    // More friction/weight
            epsilon: 0.1
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
