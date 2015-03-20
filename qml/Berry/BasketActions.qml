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
    id: bacts
    width: 100
    height: 62
    color: "#333333"

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#60000000" }
            GradientStop { position: 0.1; color: "#00000000" }
            GradientStop { position: 0.9; color: "#00000000" }
            GradientStop { position: 1.0; color: "#60000000" }
        }
    }

    property variant basket

    MouseArea {
        anchors.fill: parent
    }

    Row {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 5*Devices.density
        anchors.leftMargin: 4*Devices.density
        height: 42*Devices.density
        spacing: 10*Devices.density

        Button {
            id: clear_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: "files/edit-clear.png"
            textColor: "#ffffff"
            highlightColor: "#22ffffff"
            onClicked: {
                bacts.basket.clear()
                main.hideMenu()
            }
        }

        Button {
            id: openw_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: "files/openwidth.png"
            textColor: "#ffffff"
            highlightColor: "#22ffffff"
            onClicked: {
                main.edit(bacts.basket.toList())
                main.hideMenu()
            }
        }

        Button {
            id: cut_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: "files/edit-cut.png"
            textColor: "#ffffff"
            highlightColor: "#22ffffff"
            onClicked: {
                Berry.setCutClipboardUrl(bacts.basket.toList())
                bacts.basket.clear()
                main.hideMenu()
            }
        }

        Button {
            id: copy_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: "files/edit-copy.png"
            textColor: "#ffffff"
            highlightColor: "#22ffffff"
            onClicked: {
                Berry.setCopyClipboardUrl(bacts.basket.toList())
                main.hideMenu()
            }
        }

        Button {
            id: del_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: "files/edit-delete.png"
            textColor: "#ffffff"
            highlightColor: "#22ffffff"
            onClicked: {
                var item = showSubMessageFile(Qt.createComponent("ImageDeleteDialog.qml"))
                item.sources = bacts.basket.toList()
                item.successfully.connect(bacts.basket.clear)
                main.hideMenu()
            }
        }
    }

    LanguageSwitcher {
        onRefresh: {
            clear_btn.text = qsTr("Clear Basket")
            openw_btn.text = qsTr("Open With")
            cut_btn.text = qsTr("Cut")
            copy_btn.text = qsTr("Copy")
            del_btn.text = qsTr("Delete")
        }
    }
}
