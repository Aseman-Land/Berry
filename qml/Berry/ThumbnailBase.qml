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

Column {
    id: item_base
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.margins: viewMode? 4*Devices.density : 20*Devices.density

    property string folderPath
    property string source
    property variant filter
    property bool preview: false

    ThumbnailImage {
        id: img
        width: viewMode? item.width - 8*Devices.density : item.width - 50*Devices.density
        height: viewMode? item.height - 8*Devices.density : item.height - 50*Devices.density
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize: Qt.size(width,height)
        asynchronous: true
        smooth: true
        fillMode: Image.PreserveAspectFit
        path: item_base.source
        indicator: !fpreview.visible

        FolderPreview {
            id: fpreview
            anchors.fill: parent
            filter: item_base.filter
            path: item_base.folderPath
            visible: item_base.folderPath.length!=0
        }
    }

    Text {
        id: txt
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WrapAnywhere
        text: fileName
        font.pixelSize: 11*Devices.fontDensity
        visible: !viewMode
        color: "#dddddd"
    }
}
