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
    property string prefixText: ""
    property string icon: ""

    delegate: ItemDelegate {
        id: itemDel
        width: control.popup.width
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
            color: itemDel.hovered || itemDel.highlighted ? control.textColor : "#ccb3b5"
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
        visible: control.width > 50
        
        onPaint: {
            var context = canvas.getContext("2d")
            context.reset()
            context.moveTo(1, 1)
            context.lineTo(width / 2, height - 1)
            context.lineTo(width - 1, 1)
            context.lineWidth = 1.8
            context.strokeStyle = control.hovered || control.pressed ? control.textColor : "#966c6f"
            context.stroke()
        }
        
        Connections {
            target: control
            function onHoveredChanged() { canvas.requestPaint() }
            function onPressedChanged() { canvas.requestPaint() }
        }
    }

    Canvas {
        id: iconCanvas
        x: control.width > 50 ? 12 : (control.width - width) / 2
        y: (control.height - height) / 2
        width: 17
        height: 17
        visible: control.icon !== ""
        
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.strokeStyle = control.textColor;
            ctx.fillStyle = "transparent";
            ctx.lineWidth = 1.5;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            
            if (control.icon === "session") {
                // Monitor screen
                ctx.strokeRect(1.5, 2, 14, 10);
                // Stand
                ctx.beginPath();
                ctx.moveTo(8.5, 12);
                ctx.lineTo(8.5, 15.5);
                ctx.moveTo(5.5, 15.5);
                ctx.lineTo(11.5, 15.5);
                ctx.stroke();
            } else if (control.icon === "user") {
                // Head
                ctx.beginPath();
                ctx.arc(8.5, 5, 3, 0, 2 * Math.PI);
                ctx.stroke();
                // Shoulders
                ctx.beginPath();
                ctx.arc(8.5, 14.5, 6, -Math.PI, 0);
                ctx.stroke();
            } else if (control.icon === "power") {
                // Circle arc
                ctx.beginPath();
                ctx.arc(8.5, 9.5, 5, -0.35 * Math.PI, 1.35 * Math.PI);
                ctx.stroke();
                // Vertical line
                ctx.beginPath();
                ctx.moveTo(8.5, 3.5);
                ctx.lineTo(8.5, 9.5);
                ctx.stroke();
            }
        }
        
        Connections {
            target: control
            function onTextColorChanged() { iconCanvas.requestPaint() }
        }
    }

    contentItem: Text {
        leftPadding: control.icon !== "" ? (control.width > 50 ? 34 : 0) : 16
        rightPadding: control.width > 50 ? 30 : 0
        text: control.width > 50 ? (control.prefixText + control.displayText) : ""
        font.family: "Outfit"
        font.pixelSize: 13
        font.weight: Font.Medium
        color: control.textColor
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: control.width > 50 ? Text.AlignLeft : Text.AlignHCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 36
        color: control.color
        border.color: control.activeFocus || control.hovered ? control.textColor : control.borderColor
        border.width: 1.5
        radius: control.height / 2
        
        scale: control.hovered || control.pressed || control.activeFocus ? 1.08 : 1.0
        
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        layer.enabled: control.hovered || control.pressed || control.activeFocus
        layer.effect: Glow {
            radius: 10
            samples: 17
            color: control.textColor
            transparentBorder: true
        }
    }

    popup: Popup {
        x: (control.width - width) / 2
        y: control.height + 6
        width: Math.max(control.width, 150)
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
            border.color: (control.borderColor.a > 0) ? control.borderColor : "#4a1418"
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
