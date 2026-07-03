import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

ComboBox {
    id: control
    
    // Custom properties to mimic the previous API
    property color color: "#cc061a12"
    property color borderColor: "#226b48"
    property color textColor: "#00ff8f"
    property color hoverColor: "#1b4d36"
    property color menuColor: "#f2061a12"

    delegate: ItemDelegate {
        id: itemDel
        width: control.width
        height: 36
        
        contentItem: Text {
            text: {
                if (control.textRole && model[control.textRole] !== undefined) {
                    return model[control.textRole]
                }
                if (model.name !== undefined) return model.name
                if (modelData && modelData.name !== undefined) return modelData.name
                return modelData !== undefined ? modelData : ""
            }
            font.family: "Outfit"
            font.pixelSize: 13
            color: itemDel.hovered || itemDel.highlighted ? control.textColor : "#9acbb0"
            verticalAlignment: Text.AlignVCenter
            leftPadding: 16
            elide: Text.ElideRight
        }
        
        background: Rectangle {
            color: itemDel.hovered || itemDel.highlighted ? control.hoverColor : "transparent"
            radius: 6
            anchors.fill: parent
            anchors.margins: 2
        }
    }

    indicator: Canvas {
        id: canvas
        x: control.width - width - 14
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 6
        contextType: "2d"
        
        onPaint: {
            var context = canvas.getContext("2d")
            context.reset()
            context.moveTo(1, 1)
            context.lineTo(width / 2, height - 1)
            context.lineTo(width - 1, 1)
            context.lineWidth = 1.8
            context.strokeStyle = control.hovered || control.pressed ? control.textColor : "#7ea691"
            context.stroke()
        }
        
        Connections {
            target: control
            function onHoveredChanged() { canvas.requestPaint() }
            function onPressedChanged() { canvas.requestPaint() }
        }
    }

    contentItem: Text {
        leftPadding: 16
        rightPadding: 30
        text: control.displayText
        font.family: "Outfit"
        font.pixelSize: 13
        font.weight: Font.Medium
        color: control.textColor
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 36
        color: control.color
        border.color: control.activeFocus || control.hovered ? control.textColor : control.borderColor
        border.width: 1.5
        radius: control.height / 2
        
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    popup: Popup {
        y: control.height + 6
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 4
        
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale"; from: 0.95; to: 1.0; duration: 150; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 100; easing.type: Easing.InCubic }
            NumberAnimation { property: "scale"; from: 1.0; to: 0.95; duration: 100; easing.type: Easing.InCubic }
        }

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight > 200 ? 200 : contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            
            ScrollIndicator.vertical: ScrollIndicator { }
        }
        
        background: Rectangle {
            color: control.menuColor
            border.color: control.borderColor
            border.width: 1
            radius: 12
            
            layer.enabled: true
            layer.effect: DropShadow {
                radius: 10
                samples: 17
                color: "#dd000000"
                verticalOffset: 4
            }
        }
    }
}
