// qmllint disable uncreatable-type
import Quickshell
import QtQuick

ShellRoot {
    PanelWindow {
        id: root
        implicitHeight: 40
        anchors {
            top: true
        }
        exclusionMode: ExclusionMode.Ignore
        Rectangle {

            anchors.fill: parent
            color: 'red'
        }
    }
}
