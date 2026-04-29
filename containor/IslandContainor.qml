import QtQuick
import Quickshell
import QtQuick.Layouts

Item {
    id: root

    // This allows you to drop any widget inside the container in shell.qml
    default property alias content: container.data

    implicitWidth: container.childrenRect.width + (padding * 2)
    implicitHeight: container.childrenRect.height + (padding * 2)

    property int padding: 12
    property int radius: 16
    property int animationDuration: 350

    // The "Hugging" Logic with Animation
    width: implicitWidth
    height: implicitHeight

    Behavior on width {
        NumberAnimation {
            duration: root.animationDuration
            easing.type: Easing.OutExpo // Smooth, fast start, slow end
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: root.animationDuration
            easing.type: Easing.OutExpo
        }
    }

    // The Visual Shell
    Rectangle {
        id: background
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter

        color: "#1a1b26" // Tokyo Night-ish, or bind to your system theme
        border.color: "#3b4252"
        border.width: 1
        radius: root.radius
        clip: true // Keeps children from "bleeding" out during transitions

        Item {
            id: container
            Layout.alignment: Qt.AlignCenter
            anchors.centerIn: parent
            // This is where the magic happens:
            // All children will be centered here, and the parent
            // will animate its size to wrap around them.
        }
    }
}
