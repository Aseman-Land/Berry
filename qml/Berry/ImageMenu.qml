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

Rectangle {
    id: img_menu
    width: 100
    height: 42*Devices.density
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

    property string source
    property bool directory: Berry.isDirectory(source)
    property real menuX
    property bool isEncrypted: PasswordManager.fileIsEncrypted(img_menu.source)

    MouseArea {
        anchors.fill: parent
    }

    Row {
        x: logicX<0? 0 : (logicX>img_menu.width-width? img_menu.width-width : logicX )
        height: 42*Devices.density
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10*Devices.density

        property real logicX: menuX - width/2

        Button {
            id: cut_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: "files/edit-cut.png"
            textColor: "#ffffff"
            highlightColor: "#22ffffff"
            visible: !directory
            onClicked: {
                Berry.setCutClipboardUrl([img_menu.source])
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
            visible: !directory
            onClicked: {
                Berry.setCopyClipboardUrl([img_menu.source])
                main.hideMenu()
            }
        }

        Button {
            id: paste_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: "files/edit-paste.png"
            textColor: "#ffffff"
            highlightColor: "#22ffffff"
            visible: directory
            onClicked: {
                Berry.pasteClipboardFiles(img_menu.source)
                main.hideMenu()
            }
        }

        Button {
            id: encrypt_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: "files/lock.png"
            textColor: "#ffffff"
            highlightColor: "#22ffffff"
            visible: !viewMode && ( (directory && PasswordManager.passwordFileOf(img_menu.source).length == 0) ||
                                    (!directory && !img_menu.isEncrypted && PasswordManager.passwordFileOf(img_menu.source).length != 0) )
            onClicked: {
                var obj = showSubMessageFile("EncryptMenu.qml")
                obj.successfully.connect(img_menu.setPasswordAndEncrypt)
            }
        }

        Button {
            id: decrypt_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: "files/unlock.png"
            textColor: "#ffffff"
            highlightColor: "#22ffffff"
            visible: !viewMode && !directory && img_menu.isEncrypted
            onClicked: {
                Encypter.decryptAlongside(img_menu.source)
                main.hideMenu()
            }
        }

        Button {
            id: nfolder_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: "files/folder.png"
            textColor: "#ffffff"
            highlightColor: "#22ffffff"
            visible: directory
            onClicked: {
                var obj = showSubMessageFile("CreateFolderDialog.qml")
                obj.source = main.mainFrame.imageViewer.thumbnailBar.model.folder
                main.hideMenu()
            }
        }

        Button {
            id: rename_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: "files/edit.png"
            textColor: "#ffffff"
            highlightColor: "#22ffffff"
            visible: main.mainFrame.imageViewer.thumbnailBar.model.folder != img_menu.source
            onClicked: {
                var obj = showSubMessageFile("RenameDialog.qml")
                obj.source = img_menu.source
                main.hideMenu()
            }
        }

        Button {
            id: open_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: "files/file-manager.png"
            textColor: "#ffffff"
            highlightColor: "#22ffffff"
            visible: directory
            onClicked: {
                Berry.openDirectory(img_menu.source)
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
            visible: !directory && !img_menu.isEncrypted
            onClicked: {
                main.edit([img_menu.source])
                main.hideMenu()
            }
        }

        Button {
            id: background_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: "files/background.png"
            textColor: "#ffffff"
            highlightColor: "#22ffffff"
            visible: !directory && !img_menu.isEncrypted && (Desktop.desktopSession == AsemanDesktopTools.Gnome || Desktop.desktopSession == AsemanDesktopTools.Unity)
            onClicked: {
                Berry.setWallpaper(img_menu.source)
                main.hideMenu()
            }
        }

        Button {
            id: cover_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: "files/background.png"
            textColor: "#ffffff"
            highlightColor: "#22ffffff"
            visible: !directory && !img_menu.isEncrypted
            onClicked: {
                Berry.copyFile(img_menu.source,Berry.directoryOf(img_menu.source)+"/.cover",true)
                mainFrame.refreshCover()
                main.hideMenu()
            }
        }

        Button {
            id: dtl_btn
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            icon: "files/document-properties.png"
            textColor: "#ffffff"
            highlightColor: "#22ffffff"
            visible: !directory
            onClicked: {
                var item = showSubMessageFile("Details.qml")
                item.source = img_menu.source
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
            visible: !directory
            onClicked: {
                var item = showSubMessageFile("ImageDeleteDialog.qml")
                item.sources = [img_menu.source]
                main.hideMenu()
            }
        }
    }

    function setPasswordAndEncrypt( pass, del_files ) {
        PasswordManager.setPasswordOf( img_menu.source, pass )
        Encypter.encypt(img_menu.source,del_files)
        main.hideMenu()
    }

    LanguageSwitcher {
        onRefresh: {
            cut_btn.text = qsTr("Cut")
            copy_btn.text = qsTr("Copy")
            paste_btn.text = qsTr("Paste")
            open_btn.text = qsTr("Open")
            openw_btn.text = qsTr("Open With")
            background_btn.text = qsTr("Background")
            cover_btn.text = qsTr("Set Cover")
            dtl_btn.text = qsTr("Details")
            del_btn.text = qsTr("Delete")
            nfolder_btn.text = qsTr("New folder")
            rename_btn.text = qsTr("Rename")
            encrypt_btn.text = qsTr("Encrypt")
            decrypt_btn.text = qsTr("Decrypt")
        }
    }
}
