import QtQuick
import Quickshell
import QtQuick.Layouts
import "../widgets"

Item {
    id: root

    // This allows you to drop any widget inside the container in shell.qml
    default property alias content: container.data

    implicitWidth: Math.min(cWidth + 200, Math.max(cWidth + padding * 2, xS))
    implicitHeight: Math.min(cHeight + 200, Math.max(cHeight + padding * 2, yS))
    readonly property int cWidth: contentLoader.item ? contentLoader.item.width : 0
    readonly property int cHeight: contentLoader.item ? contentLoader.item.height : 0

    readonly property real resistance: 0.4 // Lower = heavier/more resistance
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
    property var widgets: ["../widgets/Workspace.qml", "../widgets/Launcher.qml"]
    property int currentIndex: 0

    Rectangle {
        id: background
        anchors.fill: parent

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
            anchors.centerIn: parent

            Loader {
                id: contentLoader
                asynchronous: true
                source: root.widgets[root.currentIndex]
                anchors.centerIn: parent
                opacity: status === Loader.Ready ? 1 : 0
                onLoaded: {
                    console.log("Async Load Complete:", source);
                }

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
