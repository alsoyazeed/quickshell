import QtQuick
import Quickshell
import QtQuick.Layouts
import "../widgets"

Item {
    id: root

    // This allows you to drop any widget inside the container in shell.qml
    default property alias content: container.data

    implicitWidth: baseWidth + Math.abs(stretchX) + 20
    implicitHeight: baseHeight + Math.abs(stretchY) + 10

    property real stretchX: dragHand.active ? dragHand.translation.x : 0
    property real stretchY: dragHand.active ? dragHand.translation.y : 0
    property real baseWidth: contentLoader.item ? contentLoader.item.width : 0
    property real baseHeight: contentLoader.item ? contentLoader.item.height : 0

    x: stretchX < 0 ? stretchX : 0
    y: stretchY < 0 ? stretchY : 0
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
    property var widgets: ["../widgets/Workspace.qml", "../widgets/Launcher.qml"]
    property int currentIndex: 0

    Rectangle {
        id: background
        anchors.fill: parent
        clip: true
        color: '#000000'
        border.color: "#3b4252"
        border.width: 0
        radius: 14
        DragHandler {
            id: dragHand
        }

        Item {
            id: container
            anchors {
                left: stretchX >= 0 ? parent.left : undefined
                right: stretchX < 0 ? parent.right : undefined

                top: stretchY >= 0 ? parent.top : undefined
                bottom: stretchY < 0 ? parent.bottom : undefined

                // fallback when not dragging
                horizontalCenter: dragHand.active ? undefined : parent.horizontalCenter
                verticalCenter: dragHand.active ? undefined : parent.verticalCenter
            }
            Loader {
                id: contentLoader
                asynchronous: false
                source: root.widgets[root.currentIndex]
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
