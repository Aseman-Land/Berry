import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.1

Rectangle {
    width: 100
    height: 62
    color: "#333333"

    Text {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 15*Devices.density
        width: parent.width
        font.pixelSize: 20*Devices.fontDensity
        font.weight: Font.Light
        horizontalAlignment: Text.AlignLeft
        color: "#ffffff"
    }

    Column {
        id: column
        anchors.left: parent.left
        anchors.top: title.bottom
        anchors.right: parent.right
        anchors.margins: 20*Devices.density
        spacing: 4*Devices.density

        Text {
            id: conf_btn
            width: parent.width
            font.pixelSize: 10*Devices.fontDensity
            font.weight: Font.Light
            horizontalAlignment: Text.AlignLeft
            color: "#ffffff"
        }

        ComboBox {
            width: parent.width
            onCurrentTextChanged: if(inited) Berry.currentLanguage = currentText
            Component.onCompleted: {
                var lang = Berry.currentLanguage
                model = Berry.languages
                currentIndex = find(lang)
                inited = true
            }

            property bool inited: false
        }

        Item { width:5; height: 5*Devices.density }

        CheckBox {
            id: nrml_thumb_check
            checked: Berry.nrmlThumbnailBar
            style: CheckBoxStyle {
                label: Text {
                    font.pixelSize: 10*Devices.fontDensity
                    font.weight: Font.Light
                    horizontalAlignment: Text.AlignLeft
                    color: "#ffffff"
                    text: control.text
                }
            }

            property bool lcheck: Berry.nrmlThumbnailBar
            onLcheckChanged: checked = lcheck
            onCheckedChanged: Berry.nrmlThumbnailBar = checked
        }

        Item { width:5; height: 5*Devices.density }

        CheckBox {
            id: fcr_thumb_check
            checked: Berry.fcrThumbnailBar
            style: CheckBoxStyle {
                label: Text {
                    font.pixelSize: 10*Devices.fontDensity
                    font.weight: Font.Light
                    horizontalAlignment: Text.AlignLeft
                    color: "#ffffff"
                    text: control.text
                }
            }

            property bool lcheck: Berry.fcrThumbnailBar
            onLcheckChanged: checked = lcheck
            onCheckedChanged: Berry.fcrThumbnailBar = checked
        }

        Item { width:5; height: 20*Devices.density }

        CheckBox {
            id: contrast_check
            checked: Berry.highContrast
            style: CheckBoxStyle {
                label: Text {
                    font.pixelSize: 10*Devices.fontDensity
                    font.weight: Font.Light
                    horizontalAlignment: Text.AlignLeft
                    color: "#ffffff"
                    text: control.text
                }
            }

            property bool lcheck: Berry.highContrast
            onLcheckChanged: checked = lcheck
            onCheckedChanged: Berry.highContrast = checked
        }

        Item { width:5; height: 5*Devices.density }

        CheckBox {
            id: gamma_check
            checked: Berry.highGamma
            style: CheckBoxStyle {
                label: Text {
                    font.pixelSize: 10*Devices.fontDensity
                    font.weight: Font.Light
                    horizontalAlignment: Text.AlignLeft
                    color: "#ffffff"
                    text: control.text
                }
            }

            property bool lcheck: Berry.highGamma
            onLcheckChanged: checked = lcheck
            onCheckedChanged: Berry.highGamma = checked
        }

        Item { width:5; height: 5*Devices.density }

        CheckBox {
            id: bright_check
            checked: Berry.highBright
            style: CheckBoxStyle {
                label: Text {
                    font.pixelSize: 10*Devices.fontDensity
                    font.weight: Font.Light
                    horizontalAlignment: Text.AlignLeft
                    color: "#ffffff"
                    text: control.text
                }
            }

            property bool lcheck: Berry.highBright
            onLcheckChanged: checked = lcheck
            onCheckedChanged: Berry.highBright = checked
        }
    }

    LanguageSwitcher {
        onRefresh: {
            title.text = qsTr("Configure")
            conf_btn.text = qsTr("Language")
            nrml_thumb_check.text = qsTr("Thumbnalbar")
            fcr_thumb_check.text = qsTr("Fullscreen Thumbnalbar")
            contrast_check.text = qsTr("High Contrast")
            gamma_check.text = qsTr("High Gamma")
            bright_check.text = qsTr("High Brightness")
        }
    }
}
