import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import SddmComponents 2.0

Item {
    id: root
    width: (typeof Window !== "undefined" && Window.window) ? Window.window.width : Screen.width
    height: (typeof Window !== "undefined" && Window.window) ? Window.window.height : Screen.height
    focus: true

    Keys.onPressed: (event) => {
        // Ignore navigation, tab, enter keys to prevent interfering with combo boxes or login
        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab || 
            event.key === Qt.Key_Enter || event.key === Qt.Key_Return || 
            event.key === Qt.Key_Escape) {
            return;
        }

        // If a combo box popup is open, don't hijack keyboard inputs
        if (sessionCombo.popup.visible || userCombo.popup.visible || powerCombo.popup.visible) {
            return;
        }

        // If the combo boxes themselves have active focus, don't hijack
        if (sessionCombo.activeFocus || userCombo.activeFocus || powerCombo.activeFocus) {
            return;
        }

        if (!passwordInput.activeFocus) {
            passwordInput.forceActiveFocus();
            // If it's a printable character, append it to the password field
            if (event.text.length > 0 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
                passwordInput.text += event.text;
                event.accepted = true;
            }
        }
    }

    // ── FONTS ────────────────────────────────────────────────
    FontLoader {
        id: bebasNeueFont
        source: "fonts/BebasNeue.ttf"
    }

    FontLoader {
        id: outfitFont
        source: "fonts/Outfit.ttf"
    }

    // ── BACKGROUND (Image) ───────────────────────────────────
    Image {
        id: bgImage
        anchors.fill: parent
        source: Qt.resolvedUrl(config.background || "assets/wallpaper.png")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true

        MouseArea {
            anchors.fill: parent
            onClicked: passwordInput.forceActiveFocus()
        }
    }

    // ── CENTERED GREETING AREA (Above Clock) ──────────────────────
    Item {
        id: greetingArea
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: root.height * 0.08 - 10
        width: 400
        height: 42
        opacity: 0

        Row {
            anchors.centerIn: parent
            spacing: 6

            Text {
                id: greetWord
                font.family: "Outfit"
                font.pixelSize: 40
                font.letterSpacing: 1
                font.weight: Font.Medium
                color: "#ffffff"

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
                font.pixelSize: 40
                font.letterSpacing: 1
                font.weight: Font.Medium
                color: "#ff2a4b"
                text: {
                    var count = users.count
                    var currentIdx = userCombo.currentIndex
                    var lastUser = userModel.lastUser
                    
                    if (userCombo.visible && currentIdx >= 0 && currentIdx < count) {
                        var obj = users.objectAt(currentIdx)
                        if (obj) return (obj.realName !== "" ? obj.realName : obj.userName).toUpperCase()
                    }
                    
                    if (count > 0) {
                        if (lastUser !== "") {
                            for (var i = 0; i < count; i++) {
                                var o = users.objectAt(i)
                                if (o && o.userName === lastUser) {
                                    return (o.realName !== "" ? o.realName : o.userName).toUpperCase()
                                }
                            }
                        }
                        var firstObj = users.objectAt(0)
                        if (firstObj) {
                            return (firstObj.realName !== "" ? firstObj.realName : firstObj.userName).toUpperCase()
                        }
                    }
                    return "USER"
                }
            }
        }
    }

    // Date Label (Outfit — Center-Top above Clock)
    Text {
        id: dateLabel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: greetingArea.bottom
        anchors.topMargin: 6
        font.family: "Outfit"
        font.pixelSize: 28
        font.letterSpacing: 1.5
        font.weight: Font.Normal
        color: "#ffffff"
        opacity: 0

        function update() {
            dateLabel.text = Qt.formatDate(new Date(), "dddd, MMMM dd")
        }
        Component.onCompleted: update()
        Timer {
            interval: 60000; running: true; repeat: true
            onTriggered: dateLabel.update()
        }
    }

    // ── CLOCK (Bebas Neue — Glowing Red Outline — Center-Top below Date) ───────
    Text {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: dateLabel.bottom
        anchors.topMargin: -5
        font.family: "Bebas Neue"
        font.pixelSize: Math.min(root.width * 0.19, root.height * 0.30, 300)
        color: "#090a0a" // Solid dark center matching the reference image
        style: Text.Outline
        styleColor: "#ff2a4b"
        opacity: 0
        scale: 0.96

        function update() {
            var date = new Date()
            var hours = date.getHours()
            var hours12 = hours % 12
            hours12 = hours12 ? hours12 : 12
            var minutes = date.getMinutes()
            var hoursStr = hours12 < 10 ? "0" + hours12 : "" + hours12
            var minutesStr = minutes < 10 ? "0" + minutes : "" + minutes
            clock.text = hoursStr + minutesStr
        }
        Component.onCompleted: update()
    }

    // Clock Glow Effect
    Glow {
        id: clockGlow
        anchors.fill: clock
        radius: 15
        samples: 25
        color: "#ff2a4b"
        source: clock
        opacity: clock.opacity * 0.85
        scale: clock.scale
    }

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: clock.update()
    }

    // ── CENTERED CONTENT CONTAINER (Password Input below Clock) ──
    Item {
        id: centerContent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: clock.bottom
        anchors.topMargin: 25
        width: 320
        height: 120
        opacity: 0

        transform: Translate {
            id: centerTranslate
            x: 0
            y: 30
        }

        // Password Input Box (Large pill)
        Rectangle {
            id: inputBox
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 0
            width: 280
            height: 54
            radius: 27
            color: passwordInput.activeFocus ? "#cc120507" : "#cc0d0d0d"
            border.color: passwordInput.activeFocus ? "#ff2a4b" : "transparent"
            border.width: passwordInput.activeFocus ? 1.0 : 0.0

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }
            Behavior on border.width { NumberAnimation { duration: 150 } }

            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: passwordInput.activeFocus ? 2 : 4
                radius: passwordInput.activeFocus ? 16 : 6
                samples: 25
                color: passwordInput.activeFocus ? "#b0ff2a4b" : "#60000000"
                Behavior on radius { NumberAnimation { duration: 150 } }
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on verticalOffset { NumberAnimation { duration: 150 } }
            }

            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
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

            // Container for dots to prevent overflow and handle clipping/scrolling
            Item {
                id: dotsContainer
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                clip: true

                // Placeholder Text (positioned independently of the dots row)
                Text {
                    text: "ENTER PASSWORD"
                    font.family: "Outfit"
                    font.pixelSize: 18
                    font.letterSpacing: 3.0
                    font.weight: Font.Light
                    color: "#ff2a4b"
                    opacity: 0.6
                    visible: passwordInput.text.length === 0
                    anchors.centerIn: parent
                }

                Row {
                    id: dotsRow
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: width <= parent.width ? parent.horizontalCenter : null
                    anchors.right: width > parent.width ? parent.right : null
                    spacing: 10
                    visible: passwordInput.text.length > 0

                    // Password dots when typing
                    Repeater {
                        model: passwordInput.text.length
                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            color: "#ff2a4b"
                            anchors.verticalCenter: parent.verticalCenter

                            scale: 0.0
                            opacity: 0.0

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutBack
                                }
                            }
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 120
                                }
                            }

                            Component.onCompleted: {
                                scale = 1.0;
                                opacity = 1.0;
                            }
                        }
                    }
                }
            }
        }

        // Status Message
        Text {
            id: statusMsg
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: inputBox.bottom
            anchors.topMargin: 8
            font.family: "Outfit"
            font.pixelSize: 11
            color: "#ff6b7a"
            text: ""
            opacity: 0

            Behavior on opacity {
                NumberAnimation { duration: 250 }
            }
        }

        // Caps Lock Warning
        Text {
            id: capsLockWarning
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: statusMsg.bottom
            anchors.topMargin: 6
            font.family: "Outfit"
            font.pixelSize: 11
            font.weight: Font.Normal
            color: "#ff2a4b"
            text: "⚠️ Caps Lock is ON"
            opacity: (typeof keyboard !== "undefined" && keyboard.capsLock) ? 0.8 : 0.0
            visible: opacity > 0

            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
    }

    // ── BOTTOM DOCK CONTROLS ─────────────────────────────────
    Rectangle {
        id: bottomDock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        width: dockRow.width + 52
        height: 52
        radius: 26
        color: "#cc0d0d0d"
        border.width: 1
        opacity: 0

        property bool active: sessionCombo.activeFocus || sessionCombo.hovered ||
                              (userCombo.visible && (userCombo.activeFocus || userCombo.hovered)) ||
                              powerCombo.activeFocus || powerCombo.hovered ||
                              wifiButtonArea.containsMouse
        border.color: active ? "#ff2a4b" : "#4a1418"

        Behavior on border.color { ColorAnimation { duration: 150 } }

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4
            radius: bottomDock.active ? 12 : 6
            samples: 17
            color: "#60000000"
            Behavior on radius { NumberAnimation { duration: 150 } }
        }

        Row {
            id: dockRow
            anchors.centerIn: parent
            spacing: 16

            CustomComboBox {
                id: sessionCombo
                width: 32
                height: 32
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
                prefixText: ""
                icon: "session"

                color: "transparent"
                borderColor: "transparent"
                textColor: "#ff2a4b"
                hoverColor: "#20ff2a4b"
                menuColor: "#f20d0d0d"
            }

            CustomComboBox {
                id: userCombo
                width: 120
                height: 32
                visible: users.count > 1
                model: userModel
                textRole: "realName"
                currentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                prefixText: ""
                icon: "user"

                color: "transparent"
                borderColor: "transparent"
                textColor: "#ff2a4b"
                hoverColor: "#20ff2a4b"
                menuColor: "#f20d0d0d"

                onActivated: {
                    passwordInput.text = ""
                }
            }

            // Wifi Icon Indicator
            Rectangle {
                id: wifiButton
                width: 32
                height: 32
                radius: 16
                color: wifiButtonArea.containsMouse ? "#20ff2a4b" : "transparent"
                border.color: wifiButtonArea.containsMouse ? "#ff2a4b" : "transparent"
                border.width: 1

                scale: wifiButtonArea.containsMouse ? 1.08 : 1.0

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                layer.enabled: wifiButtonArea.containsMouse
                layer.effect: Glow {
                    radius: 10
                    samples: 17
                    color: "#ff2a4b"
                    transparentBorder: true
                }

                Canvas {
                    anchors.centerIn: parent
                    width: 17
                    height: 17
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        ctx.strokeStyle = "#ff2a4b";
                        ctx.lineWidth = 1.5;
                        ctx.lineCap = "round";

                        // Dot
                        ctx.fillStyle = "#ff2a4b";
                        ctx.beginPath();
                        ctx.arc(8.5, 13.5, 1.5, 0, 2 * Math.PI);
                        ctx.fill();

                        // Arc 1
                        ctx.beginPath();
                        ctx.arc(8.5, 13.5, 5, -0.75 * Math.PI, -0.25 * Math.PI);
                        ctx.stroke();

                        // Arc 2
                        ctx.beginPath();
                        ctx.arc(8.5, 13.5, 9, -0.75 * Math.PI, -0.25 * Math.PI);
                        ctx.stroke();
                    }
                }

                MouseArea {
                    id: wifiButtonArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: checkNetworkStatus()
                }
            }

            CustomComboBox {
                id: powerCombo
                width: 32
                height: 32
                model: ["POWER", "REBOOT", "SHUTDOWN"]
                currentIndex: 0
                prefixText: ""
                icon: "power"

                color: "transparent"
                borderColor: "transparent"
                textColor: "#FF3B3B"
                hoverColor: "#20ff2a4b"
                menuColor: "#f20d0d0d"

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
            statusMsg.color   = "#ff2a4b"
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

    // ── ANIMATIONS ───────────────────────────────────────────
    ParallelAnimation {
        id: entranceAnimation

        NumberAnimation { target: clock; property: "opacity"; from: 0; to: 1; duration: 1000; easing.type: Easing.OutCubic }
        NumberAnimation { target: clock; property: "scale"; from: 0.96; to: 1.0; duration: 1000; easing.type: Easing.OutCubic }
        NumberAnimation { target: greetingArea; property: "opacity"; from: 0; to: 1; duration: 1000; easing.type: Easing.OutCubic }
        NumberAnimation { target: dateLabel; property: "opacity"; from: 0; to: 1; duration: 1000; easing.type: Easing.OutCubic }

        SequentialAnimation {
            PauseAnimation { duration: 150 }
            ParallelAnimation {
                NumberAnimation { target: centerContent; property: "opacity"; from: 0; to: 1; duration: 1000; easing.type: Easing.OutCubic }
                NumberAnimation { target: centerTranslate; property: "y"; from: 30; to: 0; duration: 1000; easing.type: Easing.OutCubic }

                NumberAnimation { target: bottomDock; property: "opacity"; from: 0; to: 1; duration: 1000; easing.type: Easing.OutCubic }
            }
        }
    }

    SequentialAnimation {
        id: shakeAnimation

        NumberAnimation { target: centerTranslate; property: "x"; to: -15; duration: 50; easing.type: Easing.OutQuad }
        NumberAnimation { target: centerTranslate; property: "x"; to: 15; duration: 80; easing.type: Easing.InOutQuad }
        NumberAnimation { target: centerTranslate; property: "x"; to: -10; duration: 80; easing.type: Easing.InOutQuad }
        NumberAnimation { target: centerTranslate; property: "x"; to: 10; duration: 80; easing.type: Easing.InOutQuad }
        NumberAnimation { target: centerTranslate; property: "x"; to: -5; duration: 80; easing.type: Easing.InOutQuad }
        NumberAnimation { target: centerTranslate; property: "x"; to: 5; duration: 80; easing.type: Easing.InOutQuad }
        NumberAnimation { target: centerTranslate; property: "x"; to: 0; duration: 50; easing.type: Easing.OutQuad }
    }

    function checkNetworkStatus() {
        statusMsg.text = "Checking connection..."
        statusMsg.color = "#ff2a4b"
        statusMsg.opacity = 1
        clearTimer.restart()

        var xhr = new XMLHttpRequest()
        xhr.open("GET", "https://clients3.google.com/generate_204", true)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 204) {
                    statusMsg.text = "Online (Wifi Connected)"
                } else {
                    statusMsg.text = "Offline / No Connection"
                }
                statusMsg.color = "#ff2a4b"
                statusMsg.opacity = 1
                clearTimer.restart()
            }
        }
        xhr.send()
    }

    // ── USER HELPER FUNCTIONS ────────────────────────────────
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