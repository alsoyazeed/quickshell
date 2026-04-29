// qmllint disable uncreatable-type
import Quickshell
import QtQuick
import QtQuick.Layouts
import "./containor"

ShellRoot {
    PanelWindow {
        id: root
        implicitHeight: 40
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
        }
    }
}
