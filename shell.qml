// qmllint disable uncreatable-type
// qmllint disable unused-imports
// qmllint disable unqualified
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "./helpers"
import "./containor"
import "./widgets"

ShellRoot {
    PanelWindow {
        id: root
        implicitHeight: 40
        HoverHandler {
            id: hoverHandb
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
        IslandState {
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
