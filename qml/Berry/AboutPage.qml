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

Rectangle {
    width: 100
    height: 62
    color: "#ececec"

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onWheel: wheel.accepted = true
    }

    Button {
        id: back_btn
        anchors.top: parent.top
        anchors.left: parent.left
        height: 40*Devices.density
        textColor: "#333333"
        highlightColor: "#44ffffff"
        icon: "files/go-previous.png"
        onClicked: main.back()
    }

    Image {
        anchors.left: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: 200*Devices.density
        height: 200*Devices.density
        sourceSize: Qt.size(width,height)
        source: "files/balloons.png"
    }

    Button {
        id: home_btn
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 70*Devices.density
        width: 240*Devices.density
        fontSize: 10*Devices.fontDensity
        height: 42*Devices.density
        normalColor: "#339DCC"
        highlightColor: "#336BCC"
        onClicked: Qt.openUrlExternally("http://aseman.co/berry")
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 256*Devices.density
            height: width
            sourceSize: Qt.size(width,height)
            fillMode: Image.PreserveAspectFit
            source: "files/icon.png"
        }

        Text {
            id: berry_txt
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 40*Devices.fontDensity
            font.family: AsemanApp.globalFont.family
            font.bold: true
            color: "#333333"
        }

        Text {
            id: about_text
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 80*Devices.density
            anchors.rightMargin: 80*Devices.density
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            font.family: AsemanApp.globalFont.family
            font.pixelSize: 12*Devices.fontDensity
            color: "#333333"
        }

        Item {
            width: 10
            height: 50*Devices.density
        }
    }

    Text {
        id: website
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8*Devices.density
        font.family: AsemanApp.globalFont.family
        font.pixelSize: 10*Devices.fontDensity
        color: "#333333"
        text: "Berry " + Berry.version()
    }

    LanguageSwitcher {
        onRefresh: {
            back_btn.text = qsTr("Back")
            home_btn.text = qsTr("Home Page")
            berry_txt.text = qsTr("Berry")
            about_text.text = Berry.aboutBerry()
        }
    }
}
