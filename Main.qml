import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import SddmComponents 2.0

Item {
    id: root
    width: Screen.width
    height: Screen.height

    // ── FONTS ────────────────────────────────────────────────
    FontLoader {
        id: bebasNeueFont
        source: "fonts/BebasNeue.ttf"
    }

    FontLoader {
        id: outfitFont
        source: "fonts/Outfit.ttf"
    }

    // ── BACKGROUND (Blurred Image) ───────────────────────────
    Image {
        id: bgImage
        anchors.fill: parent
        source: Qt.resolvedUrl(config.background || "assets/background.png")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    FastBlur {
        id: blurEffect
        anchors.fill: bgImage
        source: bgImage
        radius: 60
        visible: config.blur !== "false" && config.blur !== false
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.35
    }

    // ── CLOCK (Bebas Neue — massive center-top) ──────────────────
    Text {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: root.height * 0.10
        font.family: "Bebas Neue"
        font.pixelSize: Math.min(root.width * 0.24, root.height * 0.36, 380)
        color: "#ffffff"
        opacity: 0
        scale: 0.96

        function update() {
            var date = new Date()
            var hours = date.getHours() % 12
            hours = hours ? hours : 12
            var minutes = date.getMinutes()
            var hoursStr = hours < 10 ? "0" + hours : "" + hours
            var minutesStr = minutes < 10 ? "0" + minutes : "" + minutes
            clock.text = hoursStr + minutesStr
        }
        Component.onCompleted: update()
    }

    // Clock timer lives outside the Text element for reliability in SDDM
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: clock.update()
    }

    // ── LOGIN CARD (Glassmorphic) ───────────────────────────
    Rectangle {
        id: loginCard
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: clock.bottom
        anchors.topMargin: 20
        width: 440
        height: 290
        radius: 24
        color: "#cc061a12" // Rich dark translucent emerald
        border.color: passwordInput.activeFocus ? "#00ff8f" : "#1b4d36"
        border.width: 1.5
        opacity: 0

        transform: Translate {
            id: cardTranslate
            x: 0
            y: 30
        }

        Behavior on border.color { ColorAnimation { duration: 250 } }

        layer.enabled: true
        layer.effect: DropShadow {
            id: cardShadow
            horizontalOffset: 0
            verticalOffset: 8
            radius: passwordInput.activeFocus ? 25 : 15
            samples: 25
            color: passwordInput.activeFocus ? "#4000ff8f" : "#aa000000"
            spread: 0
            
            Behavior on radius { NumberAnimation { duration: 250 } }
            Behavior on color { ColorAnimation { duration: 250 } }
        }

        // Glowing Header Icon (Avatar Ring)
        Rectangle {
            id: avatarRing
            width: 48
            height: 48
            radius: 24
            color: "transparent"
            border.color: passwordInput.activeFocus ? "#00ff8f" : "#1b4d36"
            border.width: 1.5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 24

            Behavior on border.color { ColorAnimation { duration: 250 } }

            Rectangle {
                anchors.centerIn: parent
                width: 38
                height: 38
                radius: 19
                color: "#183324"
                
                Canvas {
                    id: lockIcon
                    anchors.centerIn: parent
                    width: 16
                    height: 18
                    contextType: "2d"
                    
                    onPaint: {
                        var ctx = lockIcon.getContext("2d")
                        ctx.reset()
                        ctx.lineWidth = 1.8
                        ctx.strokeStyle = passwordInput.activeFocus ? "#00ff8f" : "#88bfa1"
                        
                        ctx.beginPath()
                        ctx.arc(8, 7, 5, Math.PI, 0)
                        ctx.moveTo(3, 7)
                        ctx.lineTo(3, 11)
                        ctx.moveTo(13, 7)
                        ctx.lineTo(13, 11)
                        ctx.stroke()
                        
                        ctx.beginPath()
                        ctx.rect(2, 10, 12, 7)
                        ctx.fillStyle = passwordInput.activeFocus ? "#3300ff8f" : "transparent"
                        ctx.fill()
                        ctx.stroke()
                    }
                    
                    Connections {
                        target: passwordInput
                        function onActiveFocusChanged() { lockIcon.requestPaint() }
                    }
                }
            }


        }

        // Greeting
        Row {
            id: greetRow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: avatarRing.bottom
            anchors.topMargin: 20
            spacing: 0

            Text {
                id: greetWord
                font.family: "Outfit"
                font.pixelSize: 24
                font.weight: Font.Light
                color: "#9acbb0"

                function update() {
                    var h = new Date().getHours()
                    if (h < 12)      greetWord.text = "Good Morning, "
                    else if (h < 18) greetWord.text = "Good Afternoon, "
                    else             greetWord.text = "Good Evening, "
                }
                Component.onCompleted: update()
                Timer {
                    interval: 60000; running: true; repeat: true
                    onTriggered: greetWord.update()
                }
            }

            Text {
                font.family: "Outfit"
                font.pixelSize: 24
                font.weight: Font.Medium
                color: "#00ff8f"
                text: getSelectedUserRealName().toUpperCase()
            }
        }

        // Date
        Text {
            id: dateLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: greetRow.bottom
            anchors.topMargin: 6
            font.family: "Outfit"
            font.pixelSize: 14
            color: "#88bfa1"

            function update() {
                dateLabel.text = Qt.formatDate(new Date(), "dddd, MMMM dd")
            }
            Component.onCompleted: update()
            Timer {
                interval: 60000; running: true; repeat: true
                onTriggered: dateLabel.update()
            }
        }

        // Password Box
        Rectangle {
            id: inputBox
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: dateLabel.bottom
            anchors.topMargin: 36
            width: 340
            height: 48
            radius: 24
            color: passwordInput.activeFocus ? "#33061a12" : "#1a061a12"
            border.color: passwordInput.activeFocus ? "#00ff8f" : "#1b4d36"
            border.width: passwordInput.activeFocus ? 2.0 : 1.2

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }
            Behavior on border.width { NumberAnimation { duration: 150 } }

            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 4
                radius: passwordInput.activeFocus ? 15 : 6
                samples: 17
                color: passwordInput.activeFocus ? "#4000ff8f" : "#40000000"
                
                Behavior on radius { NumberAnimation { duration: 150 } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "ENTER PASSWORD"
                font.family: "Outfit"
                font.pixelSize: 11
                font.letterSpacing: 3
                font.weight: Font.Bold
                color: "#78ad94"
                opacity: passwordInput.activeFocus ? 0.35 : 0.6
                visible: !passwordInput.activeFocus && passwordInput.text.length === 0

                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            // Real input (hidden, captures keys)
            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                color: "transparent"
                selectionColor: "transparent"
                selectedTextColor: "transparent"
                font.pixelSize: 1
                cursorVisible: false
                focus: true

                Keys.onReturnPressed: doLogin()
                Keys.onEnterPressed:  doLogin()
            }

            // Custom Animated Dots and Cursor Row
            Row {
                id: dotsRow
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                
                Repeater {
                    model: 32
                    
                    Rectangle {
                        id: dot
                        property bool active: index < passwordInput.text.length
                        width: active ? 12 : 0
                        height: 12
                        radius: 6
                        color: "#00ff8f"
                        opacity: active ? 1 : 0
                        scale: active ? 1 : 0
                        visible: active || width > 0
                        
                        Behavior on width {
                            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                        }
                        Behavior on opacity {
                            NumberAnimation { duration: 120 }
                        }
                        Behavior on scale {
                            NumberAnimation { duration: 180; easing.type: active ? Easing.OutBack : Easing.OutQuad }
                        }
                    }
                }
                
                Rectangle {
                    id: customCursor
                    width: 2
                    height: 16
                    color: "#00ff8f"
                    visible: passwordInput.activeFocus
                    
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: passwordInput.activeFocus
                        
                        NumberAnimation { from: 1.0; to: 0.1; duration: 450; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 0.1; to: 1.0; duration: 450; easing.type: Easing.InOutQuad }
                    }
                }
            }
        }

        // Status Message
        Text {
            id: statusMsg
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: inputBox.bottom
            anchors.topMargin: 20
            font.family: "Outfit"
            font.pixelSize: 11
            font.letterSpacing: 2
            font.weight: Font.Bold
            color: "#ff6b7a"
            text: ""
            opacity: 0

            Behavior on opacity {
                NumberAnimation { duration: 250 }
            }
        }
    }

    // ── BOTTOM FLOATING DOCK ──────────────────────────────────
    Rectangle {
        id: bottomBar
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 80, 760)
        height: 64
        radius: 32
        color: "#cc061a12" // Rich dark translucent emerald
        border.color: "#1b4d36"
        border.width: 1.2
        
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 6
            radius: 15
            samples: 20
            color: "#80000000"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            spacing: 16

            RowLayout {
                Layout.alignment: Qt.AlignLeft
                spacing: 12

                CustomComboBox {
                    id: sessionCombo
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 38
                    model: sessionModel
                    textRole: "name"
                    currentIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
                    
                    color: "#33061a12"
                    borderColor: "#226b48"
                    textColor: "#00ff8f"
                    hoverColor: "#1b4d36"
                    menuColor: "#f2061a12"
                }

                CustomComboBox {
                    id: userCombo
                    Layout.preferredWidth: 180
                    Layout.preferredHeight: 38
                    visible: users.count > 1
                    model: userModel
                    textRole: "realName"
                    currentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                    
                    color: "#33061a12"
                    borderColor: "#226b48"
                    textColor: "#00ff8f"
                    hoverColor: "#1b4d36"
                    menuColor: "#f2061a12"
                }
            }

            Item {
                Layout.fillWidth: true
            }

            CustomComboBox {
                id: powerCombo
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: 140
                Layout.preferredHeight: 38
                model: ["POWER", "REBOOT", "SHUTDOWN"]
                currentIndex: 0
                
                color: "#33061a12"
                borderColor: "#226b48"
                textColor: "#00ff8f"
                hoverColor: "#1b4d36"
                menuColor: "#f2061a12"
                
                onActivated: (index) => {
                    if (index === 1) sddm.reboot();
                    else if (index === 2) sddm.powerOff();
                    currentIndex = 0;
                }
            }
        }
    }

    // ── LOGIN LOGIC ───────────────────────────────────────────
    function doLogin() {
        if (passwordInput.text.length === 0) return
        var user = getSelectedUsername()
        sddm.login(user, passwordInput.text, sessionCombo.currentIndex)
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            passwordInput.text  = ""
            statusMsg.text      = "ACCESS DENIED"
            statusMsg.color     = "#ff6b7a"
            statusMsg.opacity   = 1
            clearTimer.restart()
            passwordInput.forceActiveFocus()
            shakeAnimation.start()
        }

        function onLoginSucceeded() {
            statusMsg.text    = "UNLOCKING..."
            statusMsg.color   = "#00ff8f"
            statusMsg.opacity = 1
        }
    }

    Timer {
        id: clearTimer
        interval: 2200
        onTriggered: statusMsg.opacity = 0
    }

    Component.onCompleted: {
        passwordInput.forceActiveFocus()
        entranceAnimation.start()
    }

    ParallelAnimation {
        id: entranceAnimation
        
        NumberAnimation { target: clock; property: "opacity"; from: 0; to: 1; duration: 1000; easing.type: Easing.OutCubic }
        NumberAnimation { target: clock; property: "scale"; from: 0.96; to: 1.0; duration: 1000; easing.type: Easing.OutCubic }
        
        SequentialAnimation {
            PauseAnimation { duration: 150 }
            ParallelAnimation {
                NumberAnimation { target: loginCard; property: "opacity"; from: 0; to: 1; duration: 1000; easing.type: Easing.OutCubic }
                NumberAnimation { target: cardTranslate; property: "y"; from: 30; to: 0; duration: 1000; easing.type: Easing.OutCubic }
            }
        }
    }

    SequentialAnimation {
        id: shakeAnimation
        
        NumberAnimation { target: cardTranslate; property: "x"; to: -15; duration: 50; easing.type: Easing.OutQuad }
        NumberAnimation { target: cardTranslate; property: "x"; to: 15; duration: 80; easing.type: Easing.InOutQuad }
        NumberAnimation { target: cardTranslate; property: "x"; to: -10; duration: 80; easing.type: Easing.InOutQuad }
        NumberAnimation { target: cardTranslate; property: "x"; to: 10; duration: 80; easing.type: Easing.InOutQuad }
        NumberAnimation { target: cardTranslate; property: "x"; to: -5; duration: 80; easing.type: Easing.InOutQuad }
        NumberAnimation { target: cardTranslate; property: "x"; to: 5; duration: 80; easing.type: Easing.InOutQuad }
        NumberAnimation { target: cardTranslate; property: "x"; to: 0; duration: 50; easing.type: Easing.OutQuad }
    }

    // ── DYNAMIC USER HELPERS ──────────────────────────────────
    Instantiator {
        id: users
        model: userModel
        QtObject {
            property string userName: model.name
            property string realName: model.realName
        }
    }

    function getActiveUserRealName() {
        var count = users.count
        if (count === 0) return "USER"
        var lastUser = userModel.lastUser
        if (lastUser !== "") {
            for (var i = 0; i < count; i++) {
                var obj = users.objectAt(i)
                if (obj && obj.userName === lastUser) {
                    return obj.realName !== "" ? obj.realName : obj.userName
                }
            }
        }
        var firstObj = users.objectAt(0)
        if (firstObj) {
            return firstObj.realName !== "" ? firstObj.realName : firstObj.userName
        }
        return "USER"
    }

    function getActiveUsername() {
        var count = users.count
        if (count === 0) return "amit"
        var lastUser = userModel.lastUser
        if (lastUser !== "") return lastUser
        var firstObj = users.objectAt(0)
        return firstObj ? firstObj.userName : "amit"
    }

    function getSelectedUsername() {
        if (userCombo.visible && userCombo.currentIndex >= 0 && userCombo.currentIndex < users.count) {
            var obj = users.objectAt(userCombo.currentIndex)
            if (obj) return obj.userName
        }
        return getActiveUsername()
    }

    function getSelectedUserRealName() {
        if (userCombo.visible && userCombo.currentIndex >= 0 && userCombo.currentIndex < users.count) {
            var obj = users.objectAt(userCombo.currentIndex)
            if (obj) return obj.realName !== "" ? obj.realName : obj.userName
        }
        return getActiveUserRealName()
    }
}