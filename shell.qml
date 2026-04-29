// qmllint disable uncreatable-type
// qmllint disable unused-imports
// qmllint disable unqualified
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import "./helpers"
import "./containor"
import "./widgets"

ShellRoot {
    PanelWindow {
        id: root
        implicitHeight: 40

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

        exclusionMode: ExclusionMode.Normal

        WlrLayershell.layer: wlrlayer.top

        mask: Region {
            item: content.widgets
        }
        IslandState {
            id: content
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
