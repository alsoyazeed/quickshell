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

        anchors {
            top: true
            right: true
            left: true
            bottom: true
        }
        margins {
            top: 5
        }
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: wlrlayer.Top
        exclusiveZone: 10

        mask: Region {
            item: content.widgets.visible ? content.widgets : null
        }
        IslandState {
            id: content
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
