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
import land.aseman.berry 1.0
import AsemanTools 1.0

Item {
    id: details
    anchors.fill: parent

    property string source

    MouseArea {
        anchors.fill: parent
        onClicked: hideSubMessage()
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10*Devices.density
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10*Devices.density

        Image {
            id: preview
            anchors.horizontalCenter: parent.horizontalCenter
            width: 256*Devices.density
            height: width*3/4
            sourceSize: Qt.size(width,height)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            source: path_handler.output

            PathHandler {
                id: path_handler
                input: details.source
            }
        }

        Text {
            id: name_txt
            anchors.horizontalCenter: parent.horizontalCenter
            text: Berry.fileName(details.source)
            color: "#000000"
            wrapMode: Text.WrapAnywhere
            font.pixelSize: 19*Devices.density
            font.bold: true
        }

        Text {
            id: dimension_txt
            anchors.horizontalCenter: parent.horizontalCenter
            text: img_size.width + "x" + img_size.height
            color: "#000000"
            font.pixelSize: 11*Devices.density

            property size img_size: Berry.imageSize(details.source)
        }

        Text {
            id: size_txt
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.floor(Berry.fileSize(details.source)/(1024)) + "KB"
            color: "#000000"
            font.pixelSize: 11*Devices.density
        }
    }

    function hide() {
    }
}
