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
    id: thumbnailbar
    width: 100
    height: 62
    clip: true

    property real idealCellWidth: 200
    property string currentPath
    property bool showHidden: false
    property alias currentIndex: grid.currentIndex
    property real headerHeight: 0
    property alias model: grid.model

    property variant filters: [ "*brylock", "*.BRYLOCK", "*.png", "*.jpg", "*.jpeg", "*.svg", "*.svgz", "*.bmp", "*.JPG", "*.JPEG", "*.PNG" ]

    signal addSelect( string filePath )
    signal selected( string filePath )

    MouseArea {
        id: back_mouse
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: {
            var obj = main.showMenu("ImageMenu.qml", mapToItem(main,0,mouseY).y, 60*Devices.density )
            obj.source = grid.model.folder
            obj.menuX = mapToItem(main,mouseX,mouseY).x
            return
        }
    }

    GridView {
        id: grid
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: parent
        model: FileSystemModel{
            showDirs: !viewMode
            showDotAndDotDot: false
            showDirsFirst: true
            showFiles: true
            showHidden: thumbnailbar.showHidden
            sortField: FileSystemModel.Name
            nameFilters: thumbnailbar.filters
            onFolderChanged: grid.positionViewAtBeginning()
        }

        cellWidth: width/(cellCount==0? 1 : cellCount)
        cellHeight: cellCount==0? cellWidth : thumbnailbar.idealCellWidth

        property real spacing: 10*Devices.density
        property int cellCount: Math.floor(width/thumbnailbar.idealCellWidth)

        populate: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; easing.type: Easing.OutCubic; duration: 400 }
            NumberAnimation { property: "scale"; from: 0.9; to: 1.0; easing.type: Easing.OutCubic; duration: 400 }
        }

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; easing.type: Easing.OutCubic; duration: 400 }
            NumberAnimation { property: "scale"; from: 0.9; to: 1.0; easing.type: Easing.OutCubic; duration: 400 }
        }

        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.OutCubic }
        }

        header: Item {
            width: grid.width
            height: thumbnailbar.headerHeight
        }

        delegate: Item {
            id: item
            width: grid.cellWidth
            height: grid.cellHeight
            clip: true

            property bool isSelected: grid.currentIndex == index

            SystemPalette { id: myPalette; colorGroup: SystemPalette.Active }

            Rectangle {
                anchors.fill: parent
                color: myPalette.highlight
                radius: 3*Devices.density
                opacity: marea.pressed? 0.7 : highlightOpacity

                property real selectOpacity: item.isSelected && viewMode? 0.5 : 0.3
                property real normalOpacity: item.isSelected && viewMode? 0.4 : 0
                property real highlightOpacity: marea.containsMouse? selectOpacity : normalOpacity

                Behavior on opacity {
                    NumberAnimation { easing.type: Easing.OutCubic; duration: 200 }
                }
            }

            ThumbnailBase {
                source: fileIsDir? "" : filePath
                preview: fileIsDir
                filter: thumbnailbar.filters
                folderPath: fileIsDir? filePath : ""
            }

            MouseArea {
                id: marea
                hoverEnabled: true
                anchors.fill: parent
                anchors.margins: grid.spacing/2
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if( mouse.button == Qt.LeftButton && mouse.modifiers == Qt.ControlModifier ) {
                        if( fileIsDir )
                            return
                        thumbnailbar.addSelect(filePath)
                        return
                    }
                    else
                    if(mouse.button == Qt.RightButton) {
                        var obj = main.showMenu("ImageMenu.qml", mapToItem(main,0,height/2).y, 60*Devices.density )
                        obj.source = filePath
                        obj.menuX = mapToItem(main,width/2,height/2).x
                        return
                    }
                    else
                    if( fileIsDir ) {
                        if( PasswordManager.dirHasPassword(filePath) && !PasswordManager.passwordEntered(filePath) ) {
                            var obj = showSubMessageFile("GetPassDialog.qml")
                            obj.successfully.connect(marea.openDir)
                        } else {
                            ThumbnailLoader.reset()
                            grid.model.folder = filePath
                        }
                    }
                    else {
                        if( PasswordManager.fileIsEncrypted(filePath) && !PasswordManager.passwordEntered(filePath) ) {
                            var obj = showSubMessageFile("GetPassDialog.qml")
                            obj.successfully.connect(marea.openFile)
                        } else {
                            grid.currentIndex = index
                            thumbnailbar.currentPath = filePath
                            thumbnailbar.selected(filePath)
                        }
                    }
                }

                function openDir( pass ) {
                    if( !PasswordManager.checkPassword(filePath,pass) ) {
                        showSubMessageFile("IncorrectPassword.qml")
                        return
                    }

                    ThumbnailLoader.reset()
                    grid.model.folder = filePath
                }

                function openFile( pass ) {
                    if( !PasswordManager.checkPassword(filePath,pass) ) {
                        showSubMessageFile("IncorrectPassword.qml")
                        return
                    }

                    grid.currentIndex = index
                    thumbnailbar.currentPath = filePath
                    thumbnailbar.selected(filePath)
                }
            }

            Button {
                anchors.top: item.top
                anchors.left: item.left
                icon: "files/add.png"
                iconHeight: 16*Devices.density
                highlightColor: myPalette.highlight
                visible: opacity!=0
                opacity: marea.containsMouse && !fileIsDir? 1 : 0
                hoverEnabled: false
                onClicked: thumbnailbar.addSelect(filePath)

                Behavior on opacity {
                    NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
                }
            }
        }
    }

    NormalWheelScroll {
        anchors.fill: parent
        flick: grid
    }

    PhysicalScrollBar {
        scrollArea: grid; height: grid.height-headerHeight; width: 8
        anchors.right: grid.right; anchors.top: grid.top; color: "#ffffff"
        anchors.topMargin: headerHeight
    }

    function back() {
        if( grid.model.parentFolder == "" )
            return

        ThumbnailLoader.reset()
        grid.model.folder = grid.model.parentFolder
    }

    function setCurrent( filePath ) {
        currentPath = filePath
        for( var i=0; i<grid.model.count; i++ ) {
            if( grid.model.get(i,"filePath") == filePath ) {
                grid.currentIndex = i
                grid.positionViewAtIndex(i, ListView.Contain)
                return
            }
        }
    }

    function next() {
        if( !viewMode )
            return
        var idx = grid.currentIndex+1
        if( idx >= grid.count )
            return

        grid.currentIndex = idx
        thumbnailbar.currentPath = grid.model.get(idx,"filePath")
        thumbnailbar.selected(thumbnailbar.currentPath)
    }

    function prev() {
        if( !viewMode )
            return
        var idx = grid.currentIndex-1
        if( idx < 0 )
            return

        grid.currentIndex = idx
        thumbnailbar.currentPath = grid.model.get(idx,"filePath")
        thumbnailbar.selected(thumbnailbar.currentPath)
    }

    function folder() {
        return grid.model.folder
    }

    function setFolder( path ) {
        ThumbnailLoader.reset()
        grid.model.folder = path
    }

    function returnToBounds() {
        grid.returnToBounds()
    }

    function forceLayout() {
        grid.forceLayout()
    }
}
