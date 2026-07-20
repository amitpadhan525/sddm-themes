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

    // ── Fonts ────────────────────────────────────────────────────────────
    FontLoader { id: customFont;   source: "fonts/Steelfish Eb.otf" }
    FontLoader { id: oswaldFont;   source: "fonts/Oswald[wght].ttf" }

    // ── State & SDDM Bindings ──────────────────────────────────────────────
    property int  selectedUserIndex:    userModel.lastIndex    >= 0 ? userModel.lastIndex    : 0
    property int  selectedSessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property bool loginBusy: false

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

    function activeUser()    { if (users.count <= selectedUserIndex) return "User"; var o = users.objectAt(selectedUserIndex); return o ? (o.realName || o.userName) : "User" }
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
            errText.text = "Authentication failed. Please try again."
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
    //  BACKGROUND WALLPAPER & BLUR
    // ════════════════════════════════════════════════════════════════════
    Item {
        id: backgroundContainer
        anchors.fill: parent

        Rectangle { anchors.fill: parent; color: "#06070b" }

        // Wallpaper Image
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

        // Fallback gradient
        Rectangle {
            anchors.fill: parent
            visible: wallImg.status !== Image.Ready
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#0b0d19" }
                GradientStop { position: 1.0; color: "#04050a" }
            }
        }
    }

    // Glass Blur Layer (Left 35% Panel)
    Item {
        id: glassPanel
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * 0.35
        clip: true

        ShaderEffectSource {
            id: blurSource
            sourceItem: backgroundContainer
            sourceRect: Qt.rect(0, 0, glassPanel.width, glassPanel.height)
            live: true
        }

        FastBlur {
            anchors.fill: parent
            source: blurSource
            radius: 50
        }

        // Dark vignette overlay on left panel for UI readability
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(0.02, 0.03, 0.06, 0.55) }
                GradientStop { position: 0.7; color: Qt.rgba(0.02, 0.03, 0.06, 0.25) }
                GradientStop { position: 1.0; color: Qt.rgba(0.02, 0.03, 0.06, 0.05) }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: passField.forceActiveFocus()
    }

    // ════════════════════════════════════════════════════════════════════
    //  LEFT HERO CONTENT COLUMN (Harmonious & Masterwork Visual Balance)
    // ════════════════════════════════════════════════════════════════════
    Column {
        id: mainColumn
        anchors.horizontalCenter: glassPanel.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -140
        spacing: 24
        width: Math.max(clockRow.implicitWidth, 260)

        opacity: 0
        transform: Translate { id: columnSlide; y: 15 }

        ParallelAnimation {
            id: introAnim
            running: true
            NumberAnimation { target: mainColumn; property: "opacity"; from: 0; to: 1; duration: 800; easing.type: Easing.OutCubic }
            NumberAnimation { target: columnSlide; property: "y"; from: 15; to: 0; duration: 800; easing.type: Easing.OutCubic }
        }

        // ── 1. CLOCK & DATE CONTAINER ───────────────────────────────────
        Column {
            spacing: 10
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter

            // Clock Row (HH : MM)
            Row {
                id: clockRow
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: hoursText
                    font.family: oswaldFont.name !== "" ? oswaldFont.name : customFont.name
                    font.pixelSize: 230
                    font.bold: true
                    color: "#dce4ff"
                }

                // Clock Colon (Circular Dots, Proportional Size & Alignment)
                Item {
                    id: colonItem
                    width: 44
                    height: hoursText.height > 0 ? hoursText.height : 230
                    anchors.verticalCenter: hoursText.verticalCenter
                    anchors.verticalCenterOffset: 24

                    Column {
                        anchors.centerIn: parent
                        spacing: 44

                        Rectangle {
                            width: 44
                            height: 44
                            radius: 22
                            color: "#dce4ff"
                        }

                        Rectangle {
                            width: 44
                            height: 44
                            radius: 22
                            color: "#dce4ff"
                        }
                    }
                }

                Text {
                    id: minutesText
                    font.family: oswaldFont.name !== "" ? oswaldFont.name : customFont.name
                    font.pixelSize: 230
                    font.bold: true
                    color: "#dce4ff"
                }
            }

            // Date Text
            Text {
                id: dateText
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 32
                font.letterSpacing: 1.2
                font.weight: Font.DemiBold
                color: "#cbd5e1"
            }

            Component.onCompleted: tickClock()

            function tickClock() {
                var d  = new Date()
                var hh = d.getHours();   hoursText.text   = hh < 10 ? "0"+hh : ""+hh
                var mm = d.getMinutes(); minutesText.text = mm < 10 ? "0"+mm : ""+mm

                var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
                dateText.text = days[d.getDay()] + ", " + months[d.getMonth()] + " " + d.getDate()
            }
        }

        Timer { interval: 1000; running: true; repeat: true; onTriggered: mainColumn.children[0].tickClock() }

        // ── 2. PASSWORD INPUT BOX (Compact Glassmorphism) ─────
        Item {
            id: passContainer
            width: 260
            height: 44
            anchors.horizontalCenter: parent.horizontalCenter

            transform: Translate { id: passTranslate; x: 0 }

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


            // Glass container background
            Rectangle {
                id: passBg
                anchors.fill: parent
                radius: 12
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(0.12, 0.15, 0.24, 0.85) }
                    GradientStop { position: 1.0; color: Qt.rgba(0.06, 0.08, 0.14, 0.90) }
                }
                border.width: passField.activeFocus ? 1.8 : 1.2
                border.color: passField.activeFocus 
                              ? Qt.rgba(1, 1, 1, 0.35) 
                              : Qt.rgba(1, 1, 1, 0.16)
                Behavior on border.color { ColorAnimation { duration: 200 } }
            }

            // Lock Icon
            Text {
                text: "🔒"
                font.pixelSize: 13
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                opacity: 0.65
            }

            TextField {
                id: passField
                anchors.fill: parent
                anchors.leftMargin: 38
                anchors.rightMargin: 46
                echoMode: TextInput.Password
                passwordCharacter: "●"
                cursorDelegate: Item {}
                placeholderText: "Enter password..."
                placeholderTextColor: Qt.rgba(1, 1, 1, 0.40)
                color: "#ffffff"
                font.pixelSize: 14
                font.letterSpacing: passField.text.length > 0 ? 3 : 0.5
                verticalAlignment: TextInput.AlignVCenter
                focus: true
                background: Item {}
                opacity: loginBusy ? 0.0 : 1.0
                Behavior on opacity { NumberAnimation { duration: 180 } }

                onAccepted: doLogin()
            }

            // Arrow / Login Button Icon
            Rectangle {
                width: 32; height: 32; radius: 16
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                color: loginMouse.containsMouse ? "#fab387" : Qt.rgba(1, 1, 1, 0.12)
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "➜"
                    font.pixelSize: 13
                    color: loginMouse.containsMouse ? "#0f172a" : "#ffffff"
                }

                MouseArea {
                    id: loginMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: doLogin()
                }
            }

            // Busy Spinner
            Item {
                id: busySpinner
                width: 20; height: 20
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                visible: loginBusy

                Rectangle {
                    anchors.fill: parent; radius: width / 2
                    color: "transparent"; border.width: 2; border.color: Qt.rgba(1, 1, 1, 0.2)
                }

                Item {
                    anchors.fill: parent
                    RotationAnimator on rotation { from: 0; to: 360; duration: 800; loops: Animation.Infinite; running: busySpinner.visible }
                    Rectangle { width: 4; height: 4; radius: 2; color: "#fab387"; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top }
                }
            }
        }

        // Error Feedback
        Text {
            id: errText
            text: ""
            color: "#f38ba8"
            font.pixelSize: 13
            font.letterSpacing: 0.5
            anchors.horizontalCenter: parent.horizontalCenter
            visible: text.length > 0

            SequentialAnimation on opacity {
                id: errFade
                running: false
                NumberAnimation { to: 1;  duration: 0    }
                PauseAnimation  {         duration: 3000 }
                NumberAnimation { to: 0;  duration: 500  }
                onFinished: errText.text = ""
            }
        }

        // ── 4. ACTION BUTTONS (Session, User, Power) ───────────────────
        RowLayout {
            id: bottomButtons
            spacing: 16
            anchors.horizontalCenter: parent.horizontalCenter

            // Session Button
            Item {
                id: sessBtn
                width: 52; height: 52
                scale: sessMouse.containsMouse ? 1.06 : 1.0
                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

                Rectangle {
                    anchors.fill: parent; radius: 14
                    color: sessMouse.containsMouse ? Qt.rgba(0.20, 0.24, 0.36, 0.95) : Qt.rgba(0.08, 0.10, 0.18, 0.80)
                    border.color: sessMouse.containsMouse ? "#fab387" : Qt.rgba(1, 1, 1, 0.18)
                    border.width: 1.5
                    Behavior on color { ColorAnimation { duration: 140 } }
                    Behavior on border.color { ColorAnimation { duration: 140 } }
                }

                Grid {
                    columns: 2; spacing: 3; width: 16; height: 16; anchors.centerIn: parent
                    Rectangle { width: 6.5; height: 6.5; radius: 2; color: sessMouse.containsMouse ? "#fab387" : Qt.rgba(1, 1, 1, 0.80) }
                    Rectangle { width: 6.5; height: 6.5; radius: 2; color: sessMouse.containsMouse ? "#fab387" : Qt.rgba(1, 1, 1, 0.80) }
                    Rectangle { width: 6.5; height: 6.5; radius: 2; color: sessMouse.containsMouse ? "#fab387" : Qt.rgba(1, 1, 1, 0.80) }
                    Rectangle { width: 6.5; height: 6.5; radius: 2; color: sessMouse.containsMouse ? "#fab387" : Qt.rgba(1, 1, 1, 0.80) }
                }

                MouseArea {
                    id: sessMouse; anchors.fill: parent; hoverEnabled: true
                    onClicked: {
                        if (sessionPop.opened) sessionPop.close()
                        else { userPop.close(); if (powerPop.opened) powerPop.close(); sessionPop.open() }
                    }
                }
            }

            // User Switch Button
            Item {
                id: userBtn
                width: 52; height: 52
                scale: userMouse.containsMouse ? 1.06 : 1.0
                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

                Rectangle {
                    anchors.fill: parent; radius: 14
                    color: userMouse.containsMouse ? Qt.rgba(0.20, 0.24, 0.36, 0.95) : Qt.rgba(0.08, 0.10, 0.18, 0.80)
                    border.color: userMouse.containsMouse ? "#fab387" : Qt.rgba(1, 1, 1, 0.18)
                    border.width: 1.5
                    Behavior on color { ColorAnimation { duration: 140 } }
                    Behavior on border.color { ColorAnimation { duration: 140 } }
                }

                Item {
                    width: 20; height: 20; anchors.centerIn: parent
                    Rectangle { width: 9; height: 9; radius: 4.5; color: userMouse.containsMouse ? "#fab387" : Qt.rgba(1, 1, 1, 0.80); anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top }
                    Item {
                        width: 20; height: 9; anchors.bottom: parent.bottom; clip: true
                        Rectangle { width: 20; height: 20; radius: 10; color: "transparent"; border.color: userMouse.containsMouse ? "#fab387" : Qt.rgba(1, 1, 1, 0.80); border.width: 2.2; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top }
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

            // Power Menu Button
            Item {
                id: pwrBtn
                width: 52; height: 52
                scale: pwrMouse.containsMouse ? 1.06 : 1.0
                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

                Rectangle {
                    anchors.fill: parent; radius: 14
                    color: pwrMouse.containsMouse ? Qt.rgba(0.20, 0.24, 0.36, 0.95) : Qt.rgba(0.08, 0.10, 0.18, 0.80)
                    border.color: pwrMouse.containsMouse ? "#fab387" : Qt.rgba(1, 1, 1, 0.18)
                    border.width: 1.5
                    Behavior on color { ColorAnimation { duration: 140 } }
                    Behavior on border.color { ColorAnimation { duration: 140 } }
                }

                Canvas {
                    id: pwrIconCanvas
                    width: 20; height: 20; anchors.centerIn: parent
                    property color iconColor: pwrMouse.containsMouse ? "#fab387" : Qt.rgba(1, 1, 1, 0.80)
                    onIconColorChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        ctx.strokeStyle = iconColor;
                        ctx.lineWidth = 2.2;
                        ctx.lineCap = "round";
                        
                        ctx.beginPath();
                        ctx.arc(10, 10, 7.5, -Math.PI*0.3, -Math.PI*0.7, false);
                        ctx.stroke();
                        
                        ctx.beginPath();
                        ctx.moveTo(10, 2.5);
                        ctx.lineTo(10, 10);
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
    }

    // ════════════════════════════════════════════════════════════════════
    //  POPUPS (Glassmorphism & Animated Dropdowns)
    // ════════════════════════════════════════════════════════════════════
    Popup {
        id: sessionPop
        parent: sessBtn
        x: (sessBtn.width - width) / 2
        y: sessBtn.height + 10
        width: 175; height: Math.max(50, Math.min(220, sessions.count * 40 + 12))
        padding: 6; focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        background: Rectangle {
            color: Qt.rgba(0.08, 0.10, 0.18, 0.96)
            border.color: Qt.rgba(1, 1, 1, 0.18)
            border.width: 1
            radius: 14
        }

        enter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
                NumberAnimation { property: "y"; from: sessBtn.height + 2; to: sessBtn.height + 10; duration: 180; easing.type: Easing.OutCubic }
            }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 120; easing.type: Easing.OutCubic }
        }

        ListView {
            anchors.fill: parent; model: sessionModel; clip: true; spacing: 4
            delegate: Rectangle {
                width: parent ? parent.width : 0; height: 36; radius: 8
                color: selectedSessionIndex === index || sHov.containsMouse
                       ? Qt.rgba(1, 1, 1, 0.14)
                       : "transparent"
                Behavior on color { ColorAnimation { duration: 140 } }

                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; spacing: 8
                    Text {
                        text: "❖"
                        color: selectedSessionIndex === index ? "#ffffff" : Qt.rgba(1, 1, 1, 0.40)
                        font.pixelSize: 11
                    }
                    Text {
                        text: model.name
                        color: selectedSessionIndex === index || sHov.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.80)
                        font.pixelSize: 13
                        font.weight: selectedSessionIndex === index ? Font.Bold : Font.Normal
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
                MouseArea { id: sHov; anchors.fill: parent; hoverEnabled: true; onClicked: { selectedSessionIndex = index; sessionPop.close() } }
            }
        }
    }

    Popup {
        id: userPop
        parent: userBtn
        x: (userBtn.width - width) / 2
        y: userBtn.height + 10
        width: 180; height: Math.max(50, Math.min(230, users.count * 42 + 12))
        padding: 6; focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        background: Rectangle {
            color: Qt.rgba(0.08, 0.10, 0.18, 0.96)
            border.color: Qt.rgba(1, 1, 1, 0.18)
            border.width: 1
            radius: 14
        }

        enter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
                NumberAnimation { property: "y"; from: userBtn.height + 2; to: userBtn.height + 10; duration: 180; easing.type: Easing.OutCubic }
            }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 120; easing.type: Easing.OutCubic }
        }

        ListView {
            anchors.fill: parent; model: userModel; clip: true; spacing: 4
            delegate: Rectangle {
                width: parent ? parent.width : 0; height: 38; radius: 8
                color: selectedUserIndex === index || uHov.containsMouse
                       ? Qt.rgba(1, 1, 1, 0.14)
                       : "transparent"
                Behavior on color { ColorAnimation { duration: 140 } }

                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8; spacing: 10
                    Rectangle {
                        width: 24; height: 24; radius: 12
                        color: Qt.rgba(1, 1, 1, 0.15)
                        border.color: Qt.rgba(1, 1, 1, 0.25)
                        border.width: 1; clip: true
                        Image { anchors.fill: parent; source: model.icon || ""; fillMode: Image.PreserveAspectCrop; visible: model.icon !== "" }
                        Text { anchors.centerIn: parent; text: (model.realName || model.name).charAt(0).toUpperCase(); color: "#ffffff"; font.bold: true; font.pixelSize: 11; visible: !model.icon || model.icon === "" }
                    }
                    Text {
                        text: model.realName || model.name
                        color: selectedUserIndex === index || uHov.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.80)
                        font.pixelSize: 13
                        font.weight: selectedUserIndex === index ? Font.Bold : Font.Normal
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
                MouseArea { id: uHov; anchors.fill: parent; hoverEnabled: true; onClicked: { selectedUserIndex = index; userPop.close() } }
            }
        }
    }

    Popup {
        id: powerPop
        parent: pwrBtn
        x: (pwrBtn.width - width) / 2
        y: pwrBtn.height + 10
        width: 155; height: 96
        padding: 6; focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        background: Rectangle {
            color: Qt.rgba(0.08, 0.10, 0.18, 0.96)
            border.color: Qt.rgba(1, 1, 1, 0.18)
            border.width: 1
            radius: 14
        }

        enter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
                NumberAnimation { property: "y"; from: pwrBtn.height + 2; to: pwrBtn.height + 10; duration: 180; easing.type: Easing.OutCubic }
            }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 120; easing.type: Easing.OutCubic }
        }

        Column {
            anchors.fill: parent; spacing: 4
            Rectangle {
                width: parent.width; height: 40; radius: 8
                color: shHov.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : "transparent"
                Behavior on color { ColorAnimation { duration: 140 } }
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; spacing: 10
                    Text { text: "⏻"; color: shHov.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.70); font.pixelSize: 13 }
                    Text { text: "Shutdown"; color: shHov.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.85); font.pixelSize: 13; font.weight: Font.DemiBold; Layout.fillWidth: true }
                }
                MouseArea { id: shHov; anchors.fill: parent; hoverEnabled: true; onClicked: { powerPop.close(); sddm.powerOff() } }
            }
            Rectangle {
                width: parent.width; height: 40; radius: 8
                color: rbHov.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : "transparent"
                Behavior on color { ColorAnimation { duration: 140 } }
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; spacing: 10
                    Text { text: "🗘"; color: rbHov.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.70); font.pixelSize: 13 }
                    Text { text: "Reboot"; color: rbHov.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.85); font.pixelSize: 13; font.weight: Font.DemiBold; Layout.fillWidth: true }
                }
                MouseArea { id: rbHov; anchors.fill: parent; hoverEnabled: true; onClicked: { powerPop.close(); sddm.reboot() } }
            }
        }
    }
}
