// qmllint disable uncreatable-type
// qmllint disable unused-imports
// qmllint disable unqualified
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
        margins {
            top: 20
        }
        color: 'transparent'

        exclusionMode: ExclusionMode.Ignore
        mask: Region {
            item: content
        }
        IslandContainor {
            id: content
            anchors.horizontalCenter: parent.horizontalCenter
            Workspace {
                anchors.centerIn: parent
            }
        }
    }
}
