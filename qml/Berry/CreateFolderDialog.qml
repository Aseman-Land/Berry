/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    Berry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Berry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import AsemanTools 1.0

Item {
    id: ndir_dialog
    anchors.fill: parent

    property bool started: false
    property string source

    signal successfully()

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
            font.weight: Font.Light
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
                color: "#333333"
                clip: true
                onAccepted: ndir_dialog.accept()
            }

            Timer {
                interval: 200
                onTriggered: name_input.focus = true
                Component.onCompleted: start()
            }
        }

        Button {
            id: create_btn
            anchors.left: parent.left
            anchors.right: parent.right
            height: 42*Devices.density
            textColor: "#ffffff"
            normalColor: "#4098bf"
            highlightColor: "#337fa2"
            onClicked: ndir_dialog.accept()
        }
    }

    Keys.onReturnPressed: accept()

    function accept() {
        Berry.createDirectory(source + "/" + name_input.text)
        ndir_dialog.successfully()
        hideSubMessage()
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
            title_lbl.text = qsTr("Create new folder")
            name_placeholder.text = qsTr("Enter new folder name")
            create_btn.text = qsTr("Create")
        }
    }
}
