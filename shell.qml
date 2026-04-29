// qmllint disable uncreatable-type
import Quickshell
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
            left: true
            right: true
            bottom: true
        }
        color: 'transparent'

        exclusionMode: ExclusionMode.Ignore
        mask: Region {
            item: content
        }
        IslandContainor {
            id: content
            anchors.horizontalCenter: parent.horizontalCenter
            Clock {
                id: clock
                implicitWidth: hoverHand.hovered ? 190 : 100
            }
        }
    }
}
