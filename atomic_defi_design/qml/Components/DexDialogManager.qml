import QtQuick 2.15
import QtQuick.Controls 2.15
import Qaterial 1.0 as Qaterial
import QtQuick.Layouts 1.12

Popup {
    id: dialog
    width: 350
    dim: true
    modal: true
    anchors.centerIn: Overlay.overlay
    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    Overlay.modal: Item {
        DexRectangle {
            anchors.fill: parent
            color: Qt.darker(theme.dexBoxBackgroundColor)
            opacity: .6
        }
    }

    property bool warning: false

    signal accepted(string text)
    signal applied()
    signal clicked(AbstractButton button)
    signal discarded()
    signal helpRequested()
    signal rejected()
    signal reset()

    property string title: ""
    property string text: ""
    property string placeholderText: ""
    property alias iconSource: _insideLabel.icon.source
    property alias iconColor: _insideLabel.icon.color
    property alias item: _col.contentItem
    property alias itemSpacing: _insideLabel.spacing
    property int standardButtons: Dialog.NoButton
    property string yesButtonText: ""
    property string cancelButtonText: ""
    property bool getText: false
    property bool isPassword: false

    background: Qaterial.ClipRRect {
        radius: 4
        Rectangle {
            anchors.fill: parent
            radius: 4
            color: theme.surfaceColor
        }
    }

    focus: true

    contentItem: Qaterial.ClipRRect {
        height: _insideColumn.height
        radius: 4
        focus: true
        Column {
            id: _insideColumn
            width: parent.width
            padding: 0
            topPadding: 10
            spacing: 0
            Item {
                id: _header
                height: _label.height + 10
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter

                DexLabel {
                    id: _label
                    width: parent.width
                    wrapMode: Label.Wrap
                    leftPadding: 5
                    font: theme.textType.body1
                    color: theme.foregroundColor
                    anchors.verticalCenter: parent.verticalCenter
                    text: dialog.title
                }
            }
            Container {
                id: _col
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                bottomPadding: 10
                topPadding: 10
                leftPadding: 5
                contentItem: Column {
                    Qaterial.IconLabel {
                        id: _insideLabel
                        icon.source: dialog.iconSource
                        icon.width: dialog.iconSource === "" ? 0 : 48
                        icon.height: dialog.iconSource === "" ? 0 : 48
                        icon.color: dialog.iconColor
                        width: parent.width

                        text: dialog.text
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Label.AlignLeft

                        display: dialog.iconSource === "" ? AbstractButton.TextOnly : AbstractButton.TextBesideIcon
                    }

                    Item {
                        height: 10
                        width: 10
                        visible: _insideField.visible
                    }

                    DexDialogTextField {
                        id: _insideField
                        width: parent.width
                        height: 45
                        error: false
                        visible: dialog.getText
                        defaultBorderColor: theme.dexBoxBackgroundColor
                        background.border.width: 2
                        field.font: theme.textType.head6
                        field.placeholderText: dialog.placeholderText
                        field.rightPadding: dialog.isPassword ? 55 : 20
                        field.echoMode: dialog.isPassword ? TextField.Password : TextField.Normal
                        field.onAccepted: {
                            dialog.accepted(field.text)
                        }
                        Qaterial.AppBarButton {
                            visible: dialog.isPassword
                            opacity: .8
                            icon {
                                source: _insideField.field.echoMode === TextField.Password ? Qaterial.Icons.eyeOffOutline : Qaterial.Icons.eyeOutline
                                color: _insideField.field.focus ? _insideField.background.border.color : theme.accentColor
                            }
                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: 10
                            }
                            onClicked: {
                                if (_insideField.field.echoMode === TextField.Password) {
                                    _insideField.field.echoMode = TextField.Normal
                                } else {
                                    _insideField.field.echoMode = TextField.Password
                                }
                            }
                        }
                    }
                }
            }
            DialogButtonBox {
                id: _dialogButtonBox
                visible: standardButtons !== Dialog.NoButton
                standardButtons: dialog.standardButtons
                width: parent.width
                height: 60
                alignment: Qt.AlignRight
                buttonLayout: DialogButtonBox.AndroidLayout
                onAccepted: {
                    if (dialog.getText) {
                        dialog.accepted(_insideField.field.text)
                    } else {
                        dialog.accepted(undefined)
                    }
                    dialog.close()
                }
                onApplied: {
                    dialog.applied()
                    dialog.close()
                }
                onDiscarded: {
                    dialog.discarded()
                    dialog.close()
                }
                onHelpRequested: dialog.helpRequested()
                onRejected: {
                    dialog.rejected()
                    dialog.close()
                }
                onReset: dialog.reset()
                topPadding: 25
                background: Rectangle {
                    color: theme.dexBoxBackgroundColor
                }
                delegate: Qaterial.Button {
                    id: _deleteButton
                    flat: DialogButtonBox.buttonRole === DialogButtonBox.RejectRole
                    bottomInset: 0
                    topInset: 0
                    backgroundColor: DialogButtonBox.buttonRole === DialogButtonBox.RejectRole ? 'transparent' : dialog.warning ? theme.redColor : theme.accentColor
                    property alias cursorShape: mouseArea.cursorShape

                    Component.onCompleted: {
                        if (text === "Yes" && dialog.yesButtonText !== "") {
                            text = dialog.yesButtonText
                        } else if (text === "Cancel" && dialog.cancelButtonText !== "") {
                            text = dialog.cancelButtonText
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        cursorShape: "PointingHandCursor"
                        onPressed: mouse.accepted = false
                    }
                }
            }
        }
    }
}