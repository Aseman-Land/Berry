import QtQuick 2.0
import AsemanTools 1.0

Connections {
    target: Berry
    signal refresh()

    onCurrentLanguageChanged: refresh()
    Component.onCompleted: refresh()
}
