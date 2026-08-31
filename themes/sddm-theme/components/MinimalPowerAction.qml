import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property string iconSource: ""
    property string label: ""
    property color normalColor: "#cbd5e1"
    property color hoverColor: "#ffffff"
    property int iconSize: 22

    signal clicked()

    implicitWidth: Math.max(68, labelText.implicitWidth + 14)
    implicitHeight: 56

    Column {
        anchors.centerIn: parent
        spacing: 8

        Item {
            width: root.iconSize
            height: root.iconSize
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: iconImg
                anchors.fill: parent
                source: root.iconSource ? (root.iconSource.indexOf(":") !== -1 ? root.iconSource : Qt.resolvedUrl("../" + root.iconSource)) : ""
                sourceSize.width: 32
                sourceSize.height: 32
                fillMode: Image.PreserveAspectFit
                visible: false
            }

            ColorOverlay {
                anchors.fill: iconImg
                source: iconImg
                color: mouseArea.containsMouse ? root.hoverColor : root.normalColor
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        Text {
            id: labelText
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            font.family: "Outfit"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: mouseArea.containsMouse ? root.hoverColor : root.normalColor
            renderType: Text.NativeRendering
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
