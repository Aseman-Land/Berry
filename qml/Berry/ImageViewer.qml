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
    id: viewer
    width: 100
    height: 62
    color: "#00000000"

    property bool viewMode: Berry.startViewMode
    property real thumbnailBarWidth: Berry.thumbnailBar? 100*Devices.density : 0

    property alias imageSlider: img_slider
    property alias thumbnailBar: tmb_bar

    property real headerHeight: 0

    property bool showHidden: false

    property bool anim: false

    signal addSelect( string filePath )

    onViewModeChanged: {
        anim = true
        anim_disabler.restart()
        show_btn.opacityAdded = 0.6
        glow_timer.restart()
    }

    Timer {
        id: anim_disabler
        interval: show_step_timer.interval
        repeat: false
        onTriggered: viewer.anim = false
    }

    QtObject {
        id: privates
        property bool hide_step: false
    }

    Rectangle {
        id: slider_frame
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: thumbnailbar_frame.left
        width: parent.width-thumbnailBarWidth
        opacity: viewer.viewMode? 1 : 0
        clip: true
        color: Desktop.titleBarColor

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        Rectangle {
            id: slider_back
            color: "#000000"
            anchors.fill: img_slider
        }

        ImageSlider {
            id: img_slider
            anchors.fill: parent
            anchors.topMargin: viewer.headerHeight
            showHidden: viewer.showHidden
            filters: tmb_bar.filters
            onCurrentItemChanged: {
                if( tmb_bar.currentPath == currentItem )
                    return

                tmb_bar.currentPath = currentItem
                tmb_bar.setCurrent(currentItem)
            }
        }
    }

    Button {
        id: show_btn
        anchors.verticalCenter: thumbnailbar_frame.verticalCenter
        anchors.right: thumbnailbar_frame.left
        height: 40*Devices.density
        width: 13*Devices.density
        onClicked: Berry.thumbnailBar = !Berry.thumbnailBar
        normalColor: "#88000000"
        highlightColor: "#880d80ec"
        opacity: opacityAdded + (enter? 0.8 : 0.2)
        radius: 0
        text: Berry.thumbnailBar? ">" : "<"
        textColor: "#ffffff"

        property real opacityAdded: 0

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 800 }
        }

        Connections {
            target: Berry
            onThumbnailBarChanged: {
                show_btn.opacityAdded = 0.4
                glow_timer.restart()
            }
        }

        Timer {
            id: glow_timer
            interval: 400
            repeat: false
            onTriggered: show_btn.opacityAdded = 0
        }
    }

    Rectangle {
        id: thumbnailbar_frame
        x: parent.width - width
        width: main.viewMode? thumbnailBarWidth : parent.width
        height: parent.height
        color: main.viewMode && Berry.fullScreen? "#202020" : "#00000000"

        Behavior on width {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: viewer.anim? show_step_timer.interval : 0 }
        }
        Behavior on color {
            ColorAnimation{ easing.type: Easing.OutCubic; duration: viewer.anim? show_step_timer.interval : 0 }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
        }

        ThumbnailBar {
            id: tmb_bar
            width: visible? parent.width : thumbnailBarWidth
            height: parent.height
            opacity: privates.hide_step? 0 : 1
            visible: opacity != 0
            showHidden: viewer.showHidden
            onCurrentIndexChanged: img_slider.setCurrentImmedietly(currentPath)
            onAddSelect: viewer.addSelect(filePath)
            headerHeight: viewer.headerHeight
            onVisibleChanged: {
                if( visible )
                    return_timer.restart()
            }

            Timer {
                id: return_timer
                interval: 500
                repeat: false
                onTriggered: {
                    if( tmb_bar.visible )
                        tmb_bar.setCurrent(tmb_bar.currentPath)

                    tmb_bar.forceLayout()
                }
            }

            Behavior on opacity {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: hide_step_timer.interval }
            }

            onSelected: {
                var filePath = currentPath
                var folder = tmb_bar.folder()

                img_slider.source = folder
                img_slider.setCurrent( filePath )

                if( !viewer.viewMode ) {
                    privates.hide_step = true
                    hide_step_timer.back_step = false
                    hide_step_timer.restart()
                } else {
                    hide_step_timer.done()
                }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            height: 40*Devices.density
            color: Desktop.titleBarColor
            opacity: viewMode? 1 : 0
            visible: !Berry.fullScreen

            Behavior on opacity {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }
        }
    }

    Timer {
        id: hide_step_timer
        interval: Berry.initialized*150
        repeat: false
        onTriggered: done()

        function done() {
            if( back_step ) {
                viewer.viewMode = false
                show_step_timer.restart()
            } else {
                if( !viewer.viewMode )
                    show_step_timer.restart()
                viewer.viewMode = true
            }
        }

        property bool back_step: false
    }

    Timer {
        id: show_step_timer
        interval: Berry.initialized*400
        repeat: false
        onTriggered: {
            privates.hide_step = false
            tmb_bar.setCurrent( tmb_bar.currentPath )
        }
    }

    function back() {
        if( viewer.viewMode ) {
            hide_step_timer.back_step = true
            privates.hide_step = true
            hide_step_timer.restart()
        }
        else
        if( tmb_bar.back() )
            ;
        else
            return false
        return true
    }

    function openStart() {
        thumbnailBar.model.folder = Berry.startDirectory
        img_slider.source = Berry.startDirectory
        img_slider.setCurrent( Berry.inputPath )
        cunstruct_timer.restart()
    }

    function openHome() {
        viewMode = false
        thumbnailBar.model.folder = Berry.home
    }

    function passEntered(pass) {
        if( PasswordManager.fileIsEncrypted(Berry.inputPath) ) {
            if( !PasswordManager.checkPassword(Berry.inputPath,pass) ) {
                showSubMessageFile("GetPassDialog.qml").successfully.connect(viewer.passEntered)
                return
            }
        }
        else
        if( PasswordManager.passwordFileOf(Berry.inputPath).length != 0 ) {
            if( !PasswordManager.checkPassword(PasswordManager.passwordFileOf(Berry.inputPath),pass) ) {
                showSubMessageFile("GetPassDialog.qml").successfully.connect(viewer.passEntered)
                return
            }
        }

        openStart()
    }

    Timer {
        id: cunstruct_timer
        interval: 300
        repeat: false
        onTriggered: {
            img_slider.setCurrent( Berry.inputPath )
            tmb_bar.setCurrent( Berry.inputPath )
        }
    }

    Component.onCompleted: {
        if( Berry.startViewMode ) {
            if( PasswordManager.fileIsEncrypted(Berry.inputPath) )
                showSubMessageFile("GetPassDialog.qml").successfully.connect(viewer.passEntered)
            else
            if( PasswordManager.passwordFileOf(Berry.inputPath).length != 0 )
                showSubMessageFile("GetPassDialog.qml").successfully.connect(viewer.passEntered)
            else
                openStart()
        }
        else
            openHome()
    }
}
