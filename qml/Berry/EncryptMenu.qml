import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: encrypt_menu
    anchors.fill: parent

    property bool started: false

    signal successfully( string pass, bool del_files_stt )

    MouseArea {
        anchors.fill: parent
        onClicked: hideSubMessage()
    }

    Column {
        width: 300*Devices.density
        anchors.centerIn: parent
        spacing: 10*Devices.density

        Text {
            id: title_lbl
            anchors.left: parent.left
            anchors.right: parent.right
            font.pixelSize: 20*Devices.fontDensity
            font.weight: Font.Normal
            font.family: AsemanApp.globalFont.family
            horizontalAlignment: Text.AlignHCenter
            color: "#333333"
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 42*Devices.density
            color: "#88ffffff"

            Text {
                id: name_placeholder
                anchors.fill: name_input
                font: name_input.font
                verticalAlignment: name_input.verticalAlignment
                color: "#aaaaaa"
                visible: name_input.length == 0
            }

            TextInput {
                id: name_input
                anchors.fill: parent
                anchors.leftMargin: 8*Devices.density
                anchors.rightMargin: 8*Devices.density
                font.pixelSize: 10*Devices.fontDensity
                font.family: AsemanApp.globalFont.family
                verticalAlignment: Text.AlignVCenter
                selectByMouse: true
                selectionColor: "#0d80ec"
                selectedTextColor: "#ffffff"
                echoMode: TextInput.Password
                color: "#333333"
                clip: true
            }

            Timer {
                interval: 200
                onTriggered: name_input.focus = true
                Component.onCompleted: start()
            }
        }

        QCheckBox {
            id: del_files
        }

        Button {
            id: create_btn
            anchors.left: parent.left
            anchors.right: parent.right
            height: 42*Devices.density
            textColor: "#ffffff"
            normalColor: "#4098bf"
            highlightColor: "#337fa2"
            onClicked: encrypt_menu.accept()
        }
    }

    Keys.onReturnPressed: accept()

    function accept() {
        hideSubMessage()
        encrypt_menu.successfully(name_input.text,del_files.checked)
    }

    function hide() {
        started = false
    }

    Component.onCompleted: {
        started = true
        focus = true
    }
    Component.onDestruction: {
        main.focus = true
    }

    LanguageSwitcher {
        onRefresh: {
            del_files.text = qsTr("Delete files after encrypted")
            title_lbl.text = qsTr("Encrypt Menu")
            name_placeholder.text = qsTr("Enter password")
            create_btn.text = qsTr("Encrypt (Be careful. It's experimental)")
        }
    }
}
