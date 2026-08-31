import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "components"

Item {
    id: root
    width: 1920
    height: 1080
    focus: true

    // ── Font Loaders ────────────────────────────────────────────────────────
    FontLoader { id: fontOutfitBold; source: "fonts/Outfit-Bold.ttf" }
    FontLoader { id: fontBebasNeue; source: "fonts/BebasNeue.ttf" }
    FontLoader { id: fontJBMono; source: "fonts/JetBrainsMono-Regular.ttf" }
    FontLoader { id: fontJBMonoSemiBold; source: "fonts/JetBrainsMono-SemiBold.ttf" }

    // ── Configuration & Properties ──────────────────────────────────────────
    readonly property string customBg: {
        if (typeof config !== "undefined" && config) {
            if (config.Background && config.Background !== "") return config.Background
            if (config.background && config.background !== "") return config.background
        }
        return "backgrounds/background1.png"
    }
    property int batteryPercentage: (typeof config !== "undefined" && config.BatteryPercent) ? parseInt(config.BatteryPercent) : 69
    property string batteryStatusText: (typeof config !== "undefined" && config.BatteryStatus) ? config.BatteryStatus : "Discharging"

    // ── SDDM State ──────────────────────────────────────────────────────────
    property var usersList: (typeof userModel !== "undefined" && userModel) ? userModel : mockUserModel
    property var sessionsList: (typeof sessionModel !== "undefined" && sessionModel) ? sessionModel : mockSessionModel
    property int selectedUserIndex: (typeof userModel !== "undefined" && userModel && userModel.lastIndex >= 0) ? userModel.lastIndex : 0
    property int selectedSessionIndex: (typeof sessionModel !== "undefined" && sessionModel && sessionModel.lastIndex >= 0) ? sessionModel.lastIndex : 0

    property bool isLoggingIn: false
    property string feedbackMessage: ""
    property bool isErrorMessage: false
    property bool isCapsLockOn: false
    property bool showPassword: false

    ListModel {
        id: mockUserModel
        ListElement { name: "amit"; realName: "Amit" }
        ListElement { name: "guest"; realName: "Guest User" }
    }

    ListModel {
        id: mockSessionModel
        ListElement { name: "Hyprland"; file: "hyprland.desktop" }
        ListElement { name: "Hyprland (UWSM)"; file: "hyprland-uwsm.desktop" }
    }

    function getCurrentUserLoginName() {
        if (typeof userModel !== "undefined" && userModel && userModel.lastUser) {
            return userModel.lastUser
        }
        if (usersList) {
            if (typeof usersList.get === "function" && usersList.count > 0) {
                var item = usersList.get(Math.max(0, selectedUserIndex))
                if (item && (item.name || item.userName)) return item.name || item.userName
            }
            if (typeof usersList.data === "function" && typeof usersList.index === "function") {
                var val = usersList.data(usersList.index(Math.max(0, selectedUserIndex), 0), 257)
                if (val && val !== "") return val
                var dVal = usersList.data(usersList.index(Math.max(0, selectedUserIndex), 0), Qt.DisplayRole)
                if (dVal && dVal !== "") return dVal
            }
            if (usersList[selectedUserIndex] && usersList[selectedUserIndex].name) {
                return usersList[selectedUserIndex].name
            }
        }
        return "amit"
    }

    function getCurrentUserDisplayName() {
        var raw = ""
        if (usersList) {
            if (typeof usersList.get === "function" && usersList.count > 0) {
                var item = usersList.get(Math.max(0, selectedUserIndex))
                if (item) raw = item.realName || item.name || ""
            }
            if (!raw && typeof usersList.data === "function" && typeof usersList.index === "function") {
                var rName = usersList.data(usersList.index(Math.max(0, selectedUserIndex), 0), 258)
                if (rName && rName !== "") raw = rName
                if (!raw) {
                    var nName = usersList.data(usersList.index(Math.max(0, selectedUserIndex), 0), 257)
                    if (nName && nName !== "") raw = nName
                }
                if (!raw) {
                    var dName = usersList.data(usersList.index(Math.max(0, selectedUserIndex), 0), Qt.DisplayRole)
                    if (dName && dName !== "") raw = dName
                }
            }
            if (!raw && usersList[selectedUserIndex]) {
                raw = usersList[selectedUserIndex].realName || usersList[selectedUserIndex].name || ""
            }
        }
        if (!raw && typeof userModel !== "undefined" && userModel && userModel.lastUser) {
            raw = userModel.lastUser
        }
        if (!raw || raw.toLowerCase() === "user") {
            raw = "Amit"
        }
        return raw.charAt(0).toUpperCase() + raw.slice(1)
    }

    function formatSessionName(raw) {
        if (!raw) return "Hyprland"
        var s = raw.toString().trim()
        if (s.toLowerCase().indexOf("uwsm") !== -1) return "Hyprland (UWSM)"
        if (s.toLowerCase().indexOf("hyprland") !== -1) return "Hyprland"
        if (s.toLowerCase().indexOf("plasma") !== -1 || s.toLowerCase().indexOf("kde") !== -1) return "KDE Plasma"
        if (s.toLowerCase().indexOf("gnome") !== -1) return "GNOME"
        if (s.toLowerCase().indexOf("sway") !== -1) return "Sway"
        if (s.toLowerCase().indexOf("dwl") !== -1) return "DWL"
        if (s.toLowerCase().indexOf("river") !== -1) return "River"
        if (s.toLowerCase().indexOf("i3") !== -1) return "i3"

        var lastSlash = s.lastIndexOf("/")
        if (lastSlash !== -1) s = s.substring(lastSlash + 1)
        if (s.toLowerCase().endsWith(".desktop")) s = s.substring(0, s.length - 8)
        if (s.toLowerCase() === "wayland-sessions" || s.toLowerCase() === "xsessions" || s === "") return "Hyprland"
        return s.charAt(0).toUpperCase() + s.slice(1)
    }

    function getCurrentSessionDisplayName() {
        if (!sessionsList || sessionsList.count === 0) return "Hyprland"
        if (typeof sessionsList.get === "function") {
            var item = sessionsList.get(selectedSessionIndex)
            return item ? formatSessionName(item.name || item.file) : "Hyprland"
        }
        if (typeof sessionsList.data === "function") {
            var val = sessionsList.data(sessionsList.index(selectedSessionIndex, 0), 257) || sessionsList.data(sessionsList.index(selectedSessionIndex, 0), Qt.DisplayRole)
            if (val) return formatSessionName(val)
        }
        if (typeof sessionsList[selectedSessionIndex] !== "undefined") {
            return formatSessionName(sessionsList[selectedSessionIndex].name || sessionsList[selectedSessionIndex].file)
        }
        return "Hyprland"
    }

    function doLogin() {
        if (isLoggingIn) return
        var pass = passInput.text
        var uname = getCurrentUserLoginName()

        isLoggingIn = true
        feedbackMessage = ""
        isErrorMessage = false

        if (typeof sddm !== "undefined" && sddm) {
            sddm.login(uname, pass, selectedSessionIndex)
        } else {
            testTimer.restart()
        }
    }

    Timer {
        id: testTimer
        interval: 800
        onTriggered: {
            root.isLoggingIn = false
            if (passInput.text === "test" || passInput.text === "") {
                feedbackMessage = "Welcome!"
                isErrorMessage = false
            } else {
                feedbackMessage = "Incorrect password"
                isErrorMessage = true
                shakeAnim.restart()
                passInput.forceActiveFocus()
            }
        }
    }

    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: mainColumn; property: "x"; from: mainColumn.baseX; to: mainColumn.baseX - 10; duration: 50; easing.type: Easing.OutQuad }
        NumberAnimation { target: mainColumn; property: "x"; from: mainColumn.baseX - 10; to: mainColumn.baseX + 10; duration: 70; easing.type: Easing.InOutQuad }
        NumberAnimation { target: mainColumn; property: "x"; from: mainColumn.baseX + 10; to: mainColumn.baseX - 6; duration: 70; easing.type: Easing.InOutQuad }
        NumberAnimation { target: mainColumn; property: "x"; from: mainColumn.baseX - 6; to: mainColumn.baseX + 6; duration: 70; easing.type: Easing.InOutQuad }
        NumberAnimation { target: mainColumn; property: "x"; from: mainColumn.baseX + 6; to: mainColumn.baseX; duration: 50; easing.type: Easing.OutQuad }
    }

    Connections {
        target: (typeof sddm !== "undefined") ? sddm : null
        function onLoginFailed() {
            root.isLoggingIn = false
            root.feedbackMessage = "Incorrect password"
            root.isErrorMessage = true
            shakeAnim.restart()
            passInput.forceActiveFocus()
        }
        function onLoginSucceeded() {
            root.isLoggingIn = false
            root.feedbackMessage = "Welcome!"
            root.isErrorMessage = false
        }
        function onInformationMessage(msg) {
            root.feedbackMessage = msg
            root.isErrorMessage = false
        }
    }

    // Auto-focus & global keyboard typing
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_CapsLock) {
            root.isCapsLockOn = !root.isCapsLockOn
            return
        }
        if (!passInput.activeFocus && !userPopup.opened && !sessionPopup.opened) {
            passInput.forceActiveFocus()
            if (event.text.length > 0 && event.text !== "\r" && event.text !== "\n" && event.text !== "\u001b") {
                passInput.text += event.text
                event.accepted = true
            }
        }
    }

    // ── Procedural Wave Background ──────────────────────────────────────────
    WaveBackground {
        id: bgWave
        customWallpaper: root.customBg
        blurRadius: (typeof config !== "undefined" && config.BlurRadius) ? parseFloat(config.BlurRadius) : 40
    }

    // ── Main UI Left Column ─────────────────────────────────────────────────
    Item {
        id: mainColumn
        readonly property real baseX: parent.width * 0.18 - (width / 2)
        x: baseX
        y: parent.height * 0.12
        width: 320
        height: parent.height * 0.78

        // 1. Date (e.g. Monday, August 31) - Clean & Balanced
        Text {
            id: dateLabel
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
            font.family: "Outfit"
            font.pixelSize: 26
            font.weight: Font.DemiBold
            font.letterSpacing: 0.8
            color: "#ffffff"
            renderType: Text.NativeRendering

            Timer {
                interval: 60000
                running: true
                repeat: true
                onTriggered: dateLabel.text = Qt.formatDateTime(new Date(), "dddd, MMMM d")
            }
        }

        // 2. Large Time Display (e.g. 15:45)
        Text {
            id: timeLabel
            anchors.top: dateLabel.bottom
            anchors.topMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(new Date(), "HH:mm")
            font.family: "Outfit"
            font.pixelSize: 148
            font.bold: true
            font.letterSpacing: -2
            color: "#ffffff"
            renderType: Text.NativeRendering

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: timeLabel.text = Qt.formatDateTime(new Date(), "HH:mm")
            }
        }

        // 3. Middle Section: Password Box and User/Session Capsules
        Item {
            id: middleSection
            anchors.top: timeLabel.bottom
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            implicitHeight: middleCol.implicitHeight

            Column {
                id: middleCol
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16
                width: parent.width

                // ── 1. Simple, Sleek Password Input Box with Integrated Submit ──
                Rectangle {
                    id: passPill
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: 48
                    radius: 24
                    color: passInput.activeFocus ? "#151720" : Qt.rgba(0.08, 0.09, 0.13, 0.85)
                    border.color: passInput.activeFocus ? "#ea580c" : Qt.rgba(1, 1, 1, 0.14)
                    border.width: passInput.activeFocus ? 1.5 : 1

                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    Behavior on color { ColorAnimation { duration: 150 } }

                    // Subtle focus glow
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -2
                        radius: parent.radius + 2
                        color: "transparent"
                        border.color: "#ea580c"
                        border.width: 1.5
                        opacity: passInput.activeFocus ? 0.35 : 0
                        z: -1
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor
                        onClicked: passInput.forceActiveFocus()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 7
                        spacing: 10

                        // Lock Icon
                        Item {
                            width: 18
                            height: 18
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18

                            Image {
                                id: lockIconImg
                                anchors.fill: parent
                                source: "assets/lock.svg"
                                fillMode: Image.PreserveAspectFit
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: lockIconImg
                                source: lockIconImg
                                color: passInput.activeFocus ? "#ea580c" : "#64748b"
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }

                        // Password TextInput
                        TextInput {
                            id: passInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                            passwordCharacter: "●"
                            font.family: "Outfit"
                            font.pixelSize: 14
                            font.letterSpacing: root.showPassword ? 0 : 2
                            color: "#ffffff"
                            selectionColor: "#ea580c"
                            selectedTextColor: "#ffffff"
                            focus: true
                            clip: true

                            Text {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: "Password"
                                font.family: "Outfit"
                                font.pixelSize: 14
                                font.letterSpacing: 0
                                color: "#64748b"
                                visible: !passInput.text && !passInput.inputMethodComposing
                            }

                            onAccepted: root.doLogin()
                        }

                        // Eye reveal/hide password toggle
                        Item {
                            width: 26
                            height: 26
                            Layout.preferredWidth: 26
                            Layout.preferredHeight: 26
                            visible: passInput.text.length > 0

                            Image {
                                id: eyeIconImg
                                source: root.showPassword ? "assets/eye-off.svg" : "assets/eye.svg"
                                anchors.centerIn: parent
                                width: 16
                                height: 16
                                fillMode: Image.PreserveAspectFit
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: eyeIconImg
                                source: eyeIconImg
                                color: eyeMouse.containsMouse ? "#ffffff" : "#64748b"
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            MouseArea {
                                id: eyeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.showPassword = !root.showPassword
                                    passInput.forceActiveFocus()
                                }
                            }
                        }

                        // Integrated Submit Arrow Button
                        Rectangle {
                            id: submitBtn
                            width: 34
                            height: 34
                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 34
                            radius: 17
                            color: submitMouse.containsMouse ? "#ea580c" : (passInput.text.length > 0 ? Qt.rgba(0.92, 0.35, 0.05, 0.35) : Qt.rgba(1, 1, 1, 0.08))
                            scale: submitMouse.pressed ? 0.92 : (submitMouse.containsMouse ? 1.05 : 1.0)

                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on scale { NumberAnimation { duration: 120 } }

                            Text {
                                anchors.centerIn: parent
                                visible: !root.isLoggingIn
                                text: "➜"
                                font.pixelSize: 14
                                font.bold: true
                                color: submitMouse.containsMouse || passInput.text.length > 0 ? "#ffffff" : "#64748b"
                            }

                            // Loading Spinner
                            Text {
                                id: loginSpinner
                                anchors.centerIn: parent
                                visible: root.isLoggingIn
                                text: "󰑮"
                                font.family: "JetBrainsMono NF"
                                font.pixelSize: 15
                                color: "#ffffff"

                                RotationAnimation on rotation {
                                    running: root.isLoggingIn
                                    loops: Animation.Infinite
                                    from: 0
                                    to: 360
                                    duration: 800
                                }
                            }

                            MouseArea {
                                id: submitMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: !root.isLoggingIn
                                onClicked: {
                                    passInput.forceActiveFocus()
                                    root.doLogin()
                                }
                            }
                        }
                    }
                }

                // ── 2. Sleek Cohesive Glass Capsules for User & Session Switcher ──
                RowLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    // User Switcher Capsule Pill
                    Rectangle {
                        id: userActionBtn
                        implicitWidth: Math.max(120, userRowLayout.implicitWidth + 24)
                        height: 34
                        radius: 17
                        color: userMouse.containsMouse || userPopup.opened ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0.08, 0.10, 0.15, 0.85)
                        border.color: userPopup.opened ? "#ea580c" : (userMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(1, 1, 1, 0.12))
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            id: userRowLayout
                            anchors.centerIn: parent
                            spacing: 7

                            Item {
                                width: 15
                                height: 15
                                Layout.preferredWidth: 15
                                Layout.preferredHeight: 15

                                Image {
                                    id: userIconImg
                                    anchors.fill: parent
                                    source: "assets/user.svg"
                                    fillMode: Image.PreserveAspectFit
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: userIconImg
                                    source: userIconImg
                                    color: userMouse.containsMouse || userPopup.opened ? "#ffffff" : "#cbd5e1"
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                            }

                            Text {
                                id: userLabel
                                text: root.getCurrentUserDisplayName()
                                font.family: "Outfit"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: userMouse.containsMouse || userPopup.opened ? "#ffffff" : "#cbd5e1"
                                renderType: Text.NativeRendering
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            Text {
                                text: "▾"
                                font.pixelSize: 9
                                color: userMouse.containsMouse || userPopup.opened ? "#ffffff" : "#64748b"
                            }
                        }

                        MouseArea {
                            id: userMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (sessionPopup.opened) sessionPopup.close()
                                if (userPopup.opened) userPopup.close()
                                else userPopup.open()
                            }
                        }

                        Popup {
                            id: userPopup
                            y: userActionBtn.height + 6
                            x: (userActionBtn.width - width) / 2
                            width: 170
                            padding: 6
                            focus: true
                            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

                            background: Rectangle {
                                color: "#161822"
                                border.color: Qt.rgba(1, 1, 1, 0.18)
                                border.width: 1
                                radius: 12
                            }

                            contentItem: ListView {
                                id: userListView
                                implicitHeight: Math.min(contentHeight, 180)
                                clip: true
                                model: root.usersList
                                boundsBehavior: Flickable.StopAtBounds

                                delegate: Rectangle {
                                    id: userDel
                                    width: userListView.width
                                    height: 32
                                    radius: 8
                                    color: itemMouseU.containsMouse || index === root.selectedUserIndex ? Qt.rgba(1, 1, 1, index === root.selectedUserIndex ? 0.14 : 0.07) : "transparent"

                                    property string itemUserName: {
                                        if (model && model.realName !== undefined && model.realName !== "") return model.realName
                                        if (model && model.name !== undefined && model.name !== "") return model.name.charAt(0).toUpperCase() + model.name.slice(1)
                                        if (typeof realName !== "undefined" && realName !== "") return realName
                                        if (typeof name !== "undefined" && name !== "") return name.charAt(0).toUpperCase() + name.slice(1)
                                        return "Amit"
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 8

                                        Rectangle {
                                            width: 6
                                            height: 6
                                            radius: 3
                                            color: index === root.selectedUserIndex ? "#ea580c" : "transparent"
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: userDel.itemUserName
                                            font.family: "Outfit"
                                            font.pixelSize: 12
                                            font.weight: index === root.selectedUserIndex ? Font.DemiBold : Font.Normal
                                            color: index === root.selectedUserIndex ? "#ffffff" : "#cbd5e1"
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: itemMouseU
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.selectedUserIndex = index
                                            userPopup.close()
                                            passInput.forceActiveFocus()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Session Switcher Capsule Pill
                    Rectangle {
                        id: sessionActionBtn
                        implicitWidth: Math.max(120, sessRowLayout.implicitWidth + 24)
                        height: 34
                        radius: 17
                        color: sessionMouse.containsMouse || sessionPopup.opened ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0.08, 0.10, 0.15, 0.85)
                        border.color: sessionPopup.opened ? "#ea580c" : (sessionMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(1, 1, 1, 0.12))
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            id: sessRowLayout
                            anchors.centerIn: parent
                            spacing: 7

                            Item {
                                width: 15
                                height: 15
                                Layout.preferredWidth: 15
                                Layout.preferredHeight: 15

                                Image {
                                    id: sessionIconImg
                                    anchors.fill: parent
                                    source: "assets/session.svg"
                                    fillMode: Image.PreserveAspectFit
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: sessionIconImg
                                    source: sessionIconImg
                                    color: sessionMouse.containsMouse || sessionPopup.opened ? "#ffffff" : "#cbd5e1"
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                            }

                            Text {
                                id: sessionLabel
                                text: root.getCurrentSessionDisplayName()
                                font.family: "Outfit"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: sessionMouse.containsMouse || sessionPopup.opened ? "#ffffff" : "#cbd5e1"
                                renderType: Text.NativeRendering
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            Text {
                                text: "▾"
                                font.pixelSize: 9
                                color: sessionMouse.containsMouse || sessionPopup.opened ? "#ffffff" : "#64748b"
                            }
                        }

                        MouseArea {
                            id: sessionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (userPopup.opened) userPopup.close()
                                if (sessionPopup.opened) sessionPopup.close()
                                else sessionPopup.open()
                            }
                        }

                        Popup {
                            id: sessionPopup
                            y: sessionActionBtn.height + 6
                            x: (sessionActionBtn.width - width) / 2
                            width: 180
                            padding: 6
                            focus: true
                            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

                            background: Rectangle {
                                color: "#161822"
                                border.color: Qt.rgba(1, 1, 1, 0.18)
                                border.width: 1
                                radius: 12
                            }

                            contentItem: ListView {
                                id: sessionListView
                                implicitHeight: Math.min(contentHeight, 180)
                                clip: true
                                model: root.sessionsList
                                boundsBehavior: Flickable.StopAtBounds

                                delegate: Rectangle {
                                    id: sessDel
                                    width: sessionListView.width
                                    height: 32
                                    radius: 8
                                    color: itemMouseS.containsMouse || index === root.selectedSessionIndex ? Qt.rgba(1, 1, 1, index === root.selectedSessionIndex ? 0.14 : 0.07) : "transparent"

                                    property string itemSessionName: {
                                        if (model && model.name !== undefined) return root.formatSessionName(model.name)
                                        if (model && model.file !== undefined) return root.formatSessionName(model.file)
                                        if (typeof name !== "undefined") return root.formatSessionName(name)
                                        return "Desktop"
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 8

                                        Rectangle {
                                            width: 6
                                            height: 6
                                            radius: 3
                                            color: index === root.selectedSessionIndex ? "#ea580c" : "transparent"
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: sessDel.itemSessionName
                                            font.family: "Outfit"
                                            font.pixelSize: 12
                                            font.weight: index === root.selectedSessionIndex ? Font.DemiBold : Font.Normal
                                            color: index === root.selectedSessionIndex ? "#ffffff" : "#cbd5e1"
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: itemMouseS
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.selectedSessionIndex = index
                                            sessionPopup.close()
                                            passInput.forceActiveFocus()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── 3. Feedback / Error / CapsLock message ──
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.feedbackMessage !== "" || root.isCapsLockOn
                    text: root.feedbackMessage !== "" ? root.feedbackMessage : (root.isCapsLockOn ? "󰘲 Caps Lock ON" : "")
                    font.family: "Outfit"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: root.isErrorMessage ? "#ef4444" : "#f59e0b"
                    renderType: Text.NativeRendering
                }
            }
        }

        // 4. Power Controls & System Status Badge (harmoniously spaced below middleSection)
        Column {
            id: bottomSection
            anchors.top: middleSection.bottom
            anchors.topMargin: 42
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 24

            // Power Actions Row
            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 38

                MinimalPowerAction {
                    iconSource: "assets/power.svg"
                    label: "Shutdown"
                    onClicked: {
                        if (typeof sddm !== "undefined" && sddm.canPowerOff) sddm.powerOff()
                    }
                }

                MinimalPowerAction {
                    iconSource: "assets/reboot.svg"
                    label: "Restart"
                    onClicked: {
                        if (typeof sddm !== "undefined" && sddm.canReboot) sddm.reboot()
                    }
                }

                MinimalPowerAction {
                    iconSource: "assets/suspend.svg"
                    label: "Sleep"
                    onClicked: {
                        if (typeof sddm !== "undefined" && sddm.canSuspend) sddm.suspend()
                    }
                }
            }

            // System Status Pill Badge
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                implicitWidth: statusRow.implicitWidth + 28
                height: 30
                radius: 15
                color: Qt.rgba(1, 1, 1, 0.05)
                border.color: Qt.rgba(1, 1, 1, 0.10)
                border.width: 1

                RowLayout {
                    id: statusRow
                    anchors.centerIn: parent
                    spacing: 10

                    // Battery Indicator
                    RowLayout {
                        spacing: 6
                        Text {
                            text: "⚡"
                            font.pixelSize: 12
                            color: "#ea580c"
                        }
                        Text {
                            text: root.batteryPercentage + "%"
                            font.family: "Outfit"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: "#cbd5e1"
                        }
                    }

                    // Dot Divider
                    Rectangle {
                        width: 3
                        height: 3
                        radius: 1.5
                        color: "#475569"
                    }

                    // Username Tag
                    Text {
                        text: root.getCurrentUserDisplayName()
                        font.family: "Outfit"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#cbd5e1"
                    }

                    // Dot Divider
                    Rectangle {
                        width: 3
                        height: 3
                        radius: 1.5
                        color: "#475569"
                    }

                    // Desktop / Session Tag
                    Text {
                        text: root.getCurrentSessionDisplayName()
                        font.family: "Outfit"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#94a3b8"
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        passInput.forceActiveFocus()
    }
}
