import QtQuick 2.0
import AsemanTools 1.0

Item {
    anchors.fill: parent

    Indicator {
        anchors.fill: parent
        Component.onCompleted: start()
    }
}
