import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root
    width: 640
    height: 480
    focus: true

    Keys.onPressed: (event) => {
        if (!passField.activeFocus) {
            passField.forceActiveFocus()
            if (event.text.length > 0 && event.text !== "\r" && event.text !== "\n" && event.text !== "\u001b") {
                passField.text += event.text
                event.accepted = true
            }
        }
    }

    // ── PRESERVED: Steelfish font ──────────────────────────────────────────
    FontLoader { id: steelfishFont; source: "fonts/Steelfish Eb.otf" }

    // ── State ─────────────────────────────────────────────────────────────
    property int  selectedUserIndex:    userModel.lastIndex    >= 0 ? userModel.lastIndex    : 0
    property int  selectedSessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property bool loginBusy: false
    property string greetingPrefix: "Good Morning"

    onSelectedUserIndexChanged: {
        passField.text = ""
        passField.forceActiveFocus()
    }

    Instantiator {
        id: users
        model: userModel
        QtObject {
            property string userName: name
            property string realName: realName
        }
    }
    Instantiator {
        id: sessions
        model: sessionModel
        QtObject { property string sessionName: name }
    }

    function activeUser()    { if (users.count <= selectedUserIndex) return ""; var o = users.objectAt(selectedUserIndex); return o ? (o.realName || o.userName) : "" }
    function activeLogin()   { if (users.count <= selectedUserIndex) return ""; var o = users.objectAt(selectedUserIndex); return o ? o.userName : "" }
    function activeSession() { if (sessions.count <= selectedSessionIndex) return "Session"; var o = sessions.objectAt(selectedSessionIndex); return o ? o.sessionName : "Session" }

    function doLogin() {
        if (loginBusy) return
        loginBusy = true
        errText.text = ""
        sddm.login(activeLogin(), passField.text, selectedSessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            loginBusy = false
            passField.text = ""
            errText.text = "wrong password"
            errFade.restart()
            shakeAnim.restart()
            passField.forceActiveFocus()
        }
        function onLoginSucceeded() {
            root.opacity = 0
        }
    }

    Behavior on opacity { NumberAnimation { duration: 400 } }

    // ════════════════════════════════════════════════════════════════════
    //  BACKGROUND
    // ════════════════════════════════════════════════════════════════════

    Rectangle { anchors.fill: parent; color: "#08090e" }

    // Wallpaper
    Item {
        anchors.fill: parent
        visible: wallImg.status === Image.Ready

        Image {
            id: wallImg
            anchors.fill: parent
            source: (config.background && config.background.indexOf("#") !== 0)
                    ? Qt.resolvedUrl(config.background) : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
    }

    // Fallback gradient when no wallpaper
    Rectangle {
        anchors.fill: parent
        visible: wallImg.status !== Image.Ready
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#0c0e1b" }
            GradientStop { position: 1.0; color: "#060710" }
        }
    }

    // Background click-handler to restore focus to password field
    MouseArea {
        anchors.fill: parent
        onClicked: passField.forceActiveFocus()
    }

    // Welcome Back greeting above clock
    Text {
        id: welcomeText
        anchors.top: parent.top
        anchors.topMargin: 64
        anchors.horizontalCenter: parent.horizontalCenter
        text: greetingPrefix + ", " + activeUser().toUpperCase()
        font.pixelSize: 26
        font.letterSpacing: 3
        font.weight: Font.Medium
        color: Qt.rgba(1, 1, 1, 0.9)

        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 900; easing.type: Easing.OutCubic } }
        Component.onCompleted: opacity = 1
    }

    // ════════════════════════════════════════════════════════════════════
    //  CLOCK  — PRESERVED: Steelfish · 360 px · bold · pill colon
    // ════════════════════════════════════════════════════════════════════
    Item {
        id: clock
        anchors.top: welcomeText.bottom
        anchors.topMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter
        width: 558
        height: 261

        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 900; easing.type: Easing.OutCubic } }

        // PRESERVED: Pill colon
        Item {
            id: colonItem
            width: 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter:   parent.verticalCenter
            anchors.verticalCenterOffset: 18

            Rectangle {
                width: 40; height: 72; radius: 20
                color: config.textColor || "#cdd6f4"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter:   parent.verticalCenter
                anchors.verticalCenterOffset: -63
            }
            Rectangle {
                width: 40; height: 72; radius: 20
                color: config.textColor || "#cdd6f4"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter:   parent.verticalCenter
                anchors.verticalCenterOffset: 63
            }
        }

        // PRESERVED: Hours — Steelfish 324 px bold
        Text {
            id: hoursText
            font.family:    steelfishFont.name
            font.pixelSize: 324
            font.bold:      true
            color: config.textColor || "#cdd6f4"
            anchors.right:          colonItem.left
            anchors.rightMargin:    14
            anchors.verticalCenter: parent.verticalCenter
        }

        // PRESERVED: Minutes — Steelfish 324 px bold
        Text {
            id: minutesText
            font.family:    steelfishFont.name
            font.pixelSize: 324
            font.bold:      true
            color: config.textColor || "#cdd6f4"
            anchors.left:           colonItem.right
            anchors.leftMargin:     14
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: dateText
            anchors.top: hoursText.bottom
            anchors.topMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 24
            font.letterSpacing: 4
            font.weight: Font.Medium
            color: Qt.rgba(1, 1, 1, 0.6)
        }

        // Single onCompleted — start fade + tick
        Component.onCompleted: {
            opacity = 1
            tickClock()
        }

        function tickClock() {
            var d  = new Date()
            var hh = d.getHours();   hoursText.text  = hh < 10 ? "0"+hh : ""+hh
            var mm = d.getMinutes(); minutesText.text = mm < 10 ? "0"+mm : ""+mm

            var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
            dateText.text = days[d.getDay()] + " • " + d.getDate() + " " + months[d.getMonth()]

            // Dynamic Greeting based on hour
            if (hh >= 5 && hh < 12) {
                greetingPrefix = "Good Morning"
            } else if (hh >= 12 && hh < 17) {
                greetingPrefix = "Good Afternoon"
            } else if (hh >= 17 && hh < 22) {
                greetingPrefix = "Good Evening"
            } else {
                greetingPrefix = "Good Night"
            }
        }
    }

    Timer { interval: 1000; running: true; repeat: true; onTriggered: clock.tickClock() }

    // ════════════════════════════════════════════════════════════════════
    //  LOGIN AREA — no card, floating elements
    // ════════════════════════════════════════════════════════════════════
    Column {
        id: loginArea
        anchors.centerIn: parent
        spacing: 16
        width: 320

        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 700; easing.type: Easing.OutCubic } }
        Component.onCompleted: opacity = 1

        // Password input — premium rounded corner box
        Item {
            id: passContainer
            width: parent.width
            height: 48

            property bool showPassword: false

            transform: Translate {
                id: passTranslate
                x: 0
            }

            SequentialAnimation {
                id: shakeAnim
                loops: 1
                NumberAnimation { target: passTranslate; property: "x"; from: 0; to: -12; duration: 50; easing.type: Easing.OutQuad }
                NumberAnimation { target: passTranslate; property: "x"; to: 12; duration: 70; easing.type: Easing.InOutQuad }
                NumberAnimation { target: passTranslate; property: "x"; to: -8; duration: 70; easing.type: Easing.InOutQuad }
                NumberAnimation { target: passTranslate; property: "x"; to: 8; duration: 70; easing.type: Easing.InOutQuad }
                NumberAnimation { target: passTranslate; property: "x"; to: -4; duration: 70; easing.type: Easing.InOutQuad }
                NumberAnimation { target: passTranslate; property: "x"; to: 4; duration: 70; easing.type: Easing.InOutQuad }
                NumberAnimation { target: passTranslate; property: "x"; to: 0; duration: 50; easing.type: Easing.InOutQuad }
            }

            // Glow effect on focus
            RectangularGlow {
                id: passGlow
                anchors.fill: passBg
                glowRadius: 6
                spread: 0.1
                color: config.accentColor || "#cba6f7"
                cornerRadius: passBg.radius
                opacity: passField.activeFocus ? 0.35 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // Rounded corner box background and border (glass effect style matching bottom buttons)
            Rectangle {
                id: passBg
                anchors.fill: parent
                radius: 12
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.18) }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.06) }
                }
                border.width: 1.5
                border.color: passField.activeFocus 
                              ? (config.accentColor || "#cba6f7") 
                              : Qt.rgba(1, 1, 1, 0.15)
                Behavior on border.color { ColorAnimation { duration: 200 } }

                // Focused inner glass highlight layer
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    opacity: passField.activeFocus ? 1.0 : 0.0
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.12) }
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.09) }
                    }
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
            }

            TextField {
                id: passField
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                echoMode: TextInput.Password
                passwordCharacter: "●"
                cursorDelegate: Item {}
                placeholderText: "password"
                placeholderTextColor: Qt.rgba(1, 1, 1, 0.35)
                color: "#ffffff"
                font.pixelSize: passField.text.length > 0 ? 12 : 15
                font.letterSpacing: passField.text.length > 0 ? 6 : 7
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                focus: true
                background: Item {}
                opacity: loginBusy ? 0.0 : 1.0
                Behavior on opacity { NumberAnimation { duration: 180 } }

                onAccepted: doLogin()
            }

            // Busy Spinner
            Item {
                id: busySpinner
                width: 20; height: 20
                anchors.centerIn: parent
                visible: loginBusy
                opacity: loginBusy ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 180 } }

                // Background ring
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.width: 2
                    border.color: Qt.rgba(1, 1, 1, 0.1)
                }

                // Rotating indicator
                Item {
                    anchors.fill: parent
                    RotationAnimator on rotation {
                        from: 0; to: 360; duration: 800
                        loops: Animation.Infinite
                        running: busySpinner.visible
                    }
                    Rectangle {
                        width: 4; height: 4; radius: 2
                        color: config.accentColor || "#cba6f7"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                    }
                }
            }
        }

        // Error
        Text {
            id: errText
            anchors.horizontalCenter: parent.horizontalCenter
            text: ""
            color: "#f38ba8"
            font.pixelSize: 11
            font.letterSpacing: 1
            visible: text.length > 0

            SequentialAnimation on opacity {
                id: errFade
                running: false
                NumberAnimation { to: 1;  duration: 0    }
                PauseAnimation  {         duration: 2000 }
                NumberAnimation { to: 0;  duration: 500  }
                onFinished: errText.text = ""
            }
        }


    }


    // ════════════════════════════════════════════════════════════════════
    //  POPUPS
    // ════════════════════════════════════════════════════════════════════

    // Session
    Popup {
        id: sessionPop
        parent: sessBtn
        x: (sessBtn.width - width) / 2
        y: -height - 4
        width: 135
        height: Math.min(180, sessions.count * 32 + (sessions.count - 1) * 2 + 12)
        padding: 4
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        background: Item {
            id: sessionPopBg
            Rectangle {
                id: sessionPopBgRect
                anchors.fill: parent
                anchors.margins: 4
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.18) }
                    GradientStop { position: 0.3; color: Qt.rgba(0.08, 0.09, 0.14, 0.75) }
                    GradientStop { position: 1.0; color: Qt.rgba(0.05, 0.06, 0.10, 0.85) }
                }
                border.color: Qt.rgba(1, 1, 1, 0.22)
                border.width: 1
                radius: 6
            }
            DropShadow {
                anchors.fill: sessionPopBgRect
                horizontalOffset: 0; verticalOffset: 3; radius: 6; samples: 9; color: "#66000000"; source: sessionPopBgRect
            }
        }
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale";   from: 0.96; to: 1; duration: 180; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 120; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale";   from: 1; to: 0.96; duration: 120; easing.type: Easing.OutCubic }
        }

        ListView {
            anchors.fill: parent
            anchors.margins: 2
            model: sessionModel
            clip: true
            spacing: 2
            delegate: Rectangle {
                width: parent ? parent.width : 0; height: 32; radius: 4
                color: sHov.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8; spacing: 6
                    Grid {
                        columns: 2; spacing: 1.2; width: 8; height: 8
                        Layout.alignment: Qt.AlignVCenter
                        Rectangle { width: 3.4; height: 3.4; radius: 0.8; color: sHov.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.40); Behavior on color { ColorAnimation { duration: 120 } } }
                        Rectangle { width: 3.4; height: 3.4; radius: 0.8; color: sHov.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.40); Behavior on color { ColorAnimation { duration: 120 } } }
                        Rectangle { width: 3.4; height: 3.4; radius: 0.8; color: sHov.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.40); Behavior on color { ColorAnimation { duration: 120 } } }
                        Rectangle { width: 3.4; height: 3.4; radius: 0.8; color: sHov.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.40); Behavior on color { ColorAnimation { duration: 120 } } }
                    }
                    Text { text: model.name; color: sHov.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.75); font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight; Behavior on color { ColorAnimation { duration: 120 } } }
                }
                MouseArea { id: sHov; anchors.fill: parent; hoverEnabled: true; onClicked: { selectedSessionIndex = index; sessionPop.close() } }
            }
        }
    }

    // User
    Popup {
        id: userPop
        parent: userBtn
        x: (userBtn.width - width) / 2
        y: -height - 4
        width: 140
        height: Math.min(190, users.count * 36 + (users.count - 1) * 2 + 12)
        padding: 4
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        background: Item {
            id: userPopBg
            Rectangle {
                id: userPopBgRect
                anchors.fill: parent
                anchors.margins: 4
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.18) }
                    GradientStop { position: 0.3; color: Qt.rgba(0.08, 0.09, 0.14, 0.75) }
                    GradientStop { position: 1.0; color: Qt.rgba(0.05, 0.06, 0.10, 0.85) }
                }
                border.color: Qt.rgba(1, 1, 1, 0.22)
                border.width: 1
                radius: 6
            }
            DropShadow {
                anchors.fill: userPopBgRect
                horizontalOffset: 0; verticalOffset: 3; radius: 6; samples: 9; color: "#66000000"; source: userPopBgRect
            }
        }
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale";   from: 0.96; to: 1; duration: 180; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 120; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale";   from: 1; to: 0.96; duration: 120; easing.type: Easing.OutCubic }
        }

        ListView {
            anchors.fill: parent; model: userModel; clip: true; spacing: 2
            anchors.margins: 2
            delegate: Rectangle {
                width: parent ? parent.width : 0; height: 36; radius: 4
                color: uHov.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8; spacing: 8
                    Rectangle {
                        width: 20; height: 20; radius: 10
                        color: "#28ffffff"; border.color: Qt.rgba(1, 1, 1, 0.25); border.width: 1; clip: true
                        Image { anchors.fill: parent; source: model.icon || ""; fillMode: Image.PreserveAspectCrop; visible: model.icon !== "" }
                        Text { anchors.centerIn: parent; text: (model.realName || model.name).charAt(0).toUpperCase(); color: "#ffffff"; font.bold: true; font.pixelSize: 9; visible: !model.icon || model.icon === "" }
                    }
                    Text { text: model.realName || model.name; color: uHov.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.75); font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight; Behavior on color { ColorAnimation { duration: 120 } } }
                }
                MouseArea { id: uHov; anchors.fill: parent; hoverEnabled: true; onClicked: { selectedUserIndex = index; userPop.close() } }
            }
        }
    }

    // Bottom Right Circular Power Buttons
    RowLayout {
        id: bottomButtons
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 22
        anchors.rightMargin: 22
        spacing: 14

        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 1100; easing.type: Easing.OutCubic } }
        Component.onCompleted: opacity = 1

        // 1st Button: Session Change
        Item {
            id: sessBtn
            width: 38; height: 38
            scale: sessMouse.containsMouse ? 1.04 : 1.0
            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

            Rectangle {
                id: sessBtnBg
                anchors.fill: parent
                radius: 19
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.18) }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.06) }
                }
                border.color: sessMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(1, 1, 1, 0.15)
                border.width: 1
                Behavior on border.color { ColorAnimation { duration: 120 } }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    opacity: sessMouse.containsMouse ? 1.0 : 0.0
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.30) }
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.15) }
                    }
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }
            }

            Grid {
                columns: 2; spacing: 1.5; width: 11; height: 11
                anchors.centerIn: parent
                Rectangle { width: 4.5; height: 4.5; radius: 1; color: sessMouse.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.65); Behavior on color { ColorAnimation { duration: 120 } } }
                Rectangle { width: 4.5; height: 4.5; radius: 1; color: sessMouse.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.65); Behavior on color { ColorAnimation { duration: 120 } } }
                Rectangle { width: 4.5; height: 4.5; radius: 1; color: sessMouse.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.65); Behavior on color { ColorAnimation { duration: 120 } } }
                Rectangle { width: 4.5; height: 4.5; radius: 1; color: sessMouse.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.65); Behavior on color { ColorAnimation { duration: 120 } } }
            }

            MouseArea {
                id: sessMouse; anchors.fill: parent; hoverEnabled: true
                onClicked: {
                    if (sessionPop.opened) sessionPop.close()
                    else { userPop.close(); if (powerPop.opened) powerPop.close(); sessionPop.open() }
                }
            }
        }

        // 2nd Button: User Change
        Item {
            id: userBtn
            width: 38; height: 38
            scale: userMouse.containsMouse ? 1.04 : 1.0
            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

            Rectangle {
                id: userBtnBg
                anchors.fill: parent
                radius: 19
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.18) }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.06) }
                }
                border.color: userMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(1, 1, 1, 0.15)
                border.width: 1
                Behavior on border.color { ColorAnimation { duration: 120 } }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    opacity: userMouse.containsMouse ? 1.0 : 0.0
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.30) }
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.15) }
                    }
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }
            }

            Item {
                width: 14; height: 14
                anchors.centerIn: parent
                Rectangle {
                    width: 6; height: 6; radius: 3
                    color: userMouse.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.65)
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                Item {
                    width: 14; height: 6
                    anchors.bottom: parent.bottom
                    clip: true
                    Rectangle {
                        width: 14; height: 14; radius: 7
                        color: "transparent"
                        border.color: userMouse.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.65)
                        border.width: 1.8
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        Behavior on border.color { ColorAnimation { duration: 120 } }
                    }
                }
            }

            MouseArea {
                id: userMouse; anchors.fill: parent; hoverEnabled: true
                onClicked: {
                    if (userPop.opened) userPop.close()
                    else { sessionPop.close(); if (powerPop.opened) powerPop.close(); userPop.open() }
                }
            }
        }

        // 3rd Button: Power Menu
        Item {
            id: pwrBtn
            width: 38; height: 38
            scale: pwrMouse.containsMouse ? 1.04 : 1.0
            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

            Rectangle {
                id: pwrBtnBg
                anchors.fill: parent
                radius: 19
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.18) }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.06) }
                }
                border.color: pwrMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(1, 1, 1, 0.15)
                border.width: 1
                Behavior on border.color { ColorAnimation { duration: 120 } }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    opacity: pwrMouse.containsMouse ? 1.0 : 0.0
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.30) }
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.15) }
                    }
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }
            }

            Canvas {
                id: pwrIconCanvas
                width: 14; height: 14
                anchors.centerIn: parent
                property color iconColor: pwrMouse.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.65)
                onIconColorChanged: requestPaint()
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.strokeStyle = iconColor;
                    ctx.lineWidth = 1.8;
                    ctx.lineCap = "round";
                    
                    ctx.beginPath();
                    ctx.arc(7, 7, 5.2, -Math.PI*0.3, -Math.PI*0.7, false);
                    ctx.stroke();
                    
                    ctx.beginPath();
                    ctx.moveTo(7, 2.0);
                    ctx.lineTo(7, 7);
                    ctx.stroke();
                }
            }

            MouseArea {
                id: pwrMouse; anchors.fill: parent; hoverEnabled: true
                onClicked: {
                    if (powerPop.opened) powerPop.close()
                    else { sessionPop.close(); userPop.close(); powerPop.open() }
                }
            }
        }
    }

    // Power Popup
    Popup {
        id: powerPop
        parent: pwrBtn
        x: (pwrBtn.width - width) / 2
        y: -height - 4
        width: 110
        height: 80
        padding: 4
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        background: Item {
            id: powerPopBg
            Rectangle {
                id: powerPopBgRect
                anchors.fill: parent
                anchors.margins: 4
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.18) }
                    GradientStop { position: 0.3; color: Qt.rgba(0.08, 0.09, 0.14, 0.75) }
                    GradientStop { position: 1.0; color: Qt.rgba(0.05, 0.06, 0.10, 0.85) }
                }
                border.color: Qt.rgba(1, 1, 1, 0.22)
                border.width: 1
                radius: 6
            }
            DropShadow {
                anchors.fill: powerPopBgRect
                horizontalOffset: 0; verticalOffset: 3; radius: 6; samples: 9; color: "#66000000"; source: powerPopBgRect
            }
        }
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale";   from: 0.96; to: 1; duration: 180; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 120; easing.type: Easing.OutCubic }
            NumberAnimation { property: "scale";   from: 1; to: 0.96; duration: 120; easing.type: Easing.OutCubic }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 2
            spacing: 4
            Rectangle {
                width: parent.width; height: 32; radius: 4
                color: shHov.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8; spacing: 8
                    Canvas {
                        id: shIconCanvas
                        width: 12; height: 12
                        property color iconColor: shHov.containsMouse ? "#ff5555" : Qt.rgba(1, 1, 1, 0.65)
                        onIconColorChanged: requestPaint()
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            ctx.strokeStyle = iconColor;
                            ctx.lineWidth = 1.5;
                            ctx.lineCap = "round";
                            
                            ctx.beginPath();
                            ctx.arc(6, 6, 4.2, -Math.PI*0.3, -Math.PI*0.7, false);
                            ctx.stroke();
                            
                            ctx.beginPath();
                            ctx.moveTo(6, 1.8);
                            ctx.lineTo(6, 6);
                            ctx.stroke();
                        }
                    }
                    Text { text: "Shutdown"; color: shHov.containsMouse ? "#ff5555" : Qt.rgba(1, 1, 1, 0.75); font.pixelSize: 11; Layout.fillWidth: true; Behavior on color { ColorAnimation { duration: 120 } } }
                }
                MouseArea { id: shHov; anchors.fill: parent; hoverEnabled: true; onClicked: { powerPop.close(); sddm.powerOff() } }
            }
            Rectangle {
                width: parent.width; height: 32; radius: 4
                color: rbHov.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8; spacing: 8
                    Text { text: "↺"; color: rbHov.containsMouse ? "#50fa7b" : Qt.rgba(1, 1, 1, 0.65); font.pixelSize: 12; Behavior on color { ColorAnimation { duration: 120 } } }
                    Text { text: "Reboot"; color: rbHov.containsMouse ? "#50fa7b" : Qt.rgba(1, 1, 1, 0.75); font.pixelSize: 11; Layout.fillWidth: true; Behavior on color { ColorAnimation { duration: 120 } } }
                }
                MouseArea { id: rbHov; anchors.fill: parent; hoverEnabled: true; onClicked: { powerPop.close(); sddm.reboot() } }
            }
        }
    }
}
