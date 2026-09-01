import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    anchors.fill: parent

    property string customWallpaper: ""
    property real blurRadius: 40

    // Base deep black background
    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    // Custom wallpaper image
    Image {
        id: bgImg
        anchors.fill: parent
        source: root.customWallpaper ? (root.customWallpaper.indexOf(":") !== -1 ? root.customWallpaper : Qt.resolvedUrl("../" + root.customWallpaper)) : ""
        fillMode: Image.PreserveAspectCrop
        visible: root.blurRadius <= 0 && root.customWallpaper !== ""
        asynchronous: false
    }

    // Smooth procedural vector organic wave (used only as fallback if no wallpaper is set)
    Canvas {
        id: waveCanvas
        anchors.fill: parent
        visible: root.blurRadius <= 0 && root.customWallpaper === ""
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Threaded

        onPaint: {
            var ctx = getContext("2d")
            var w = width
            var h = height

            ctx.clearRect(0, 0, w, h)

            // 1. Pure Pitch Black Background
            ctx.fillStyle = "#000000"
            ctx.fillRect(0, 0, w, h)

            // 2. Bottom-left subtle smooth dark red glow
            var radGlowBL = ctx.createRadialGradient(0, h * 0.95, 10, 0, h * 0.95, h * 0.5)
            radGlowBL.addColorStop(0.0, "rgba(130, 15, 15, 0.35)")
            radGlowBL.addColorStop(0.5, "rgba(70, 8, 8, 0.12)")
            radGlowBL.addColorStop(1.0, "rgba(0, 0, 0, 0.0)")
            ctx.fillStyle = radGlowBL
            ctx.fillRect(0, 0, w * 0.5, h)

            // 3. Main Organic Wave Shape
            ctx.save()
            ctx.beginPath()

            // Start at bottom-left corner
            ctx.moveTo(0, h)
            ctx.lineTo(0, h * 0.84)

            // Smooth lower valley
            ctx.bezierCurveTo(w * 0.10, h * 0.89, w * 0.22, h * 0.88, w * 0.38, h * 0.62)

            // Smooth climb towards upper crest
            ctx.bezierCurveTo(w * 0.50, h * 0.40, w * 0.60, h * 0.045, w * 0.75, h * 0.035)

            // Smooth rounded top dome and descent to right edge
            ctx.bezierCurveTo(w * 0.87, h * 0.03, w * 0.97, h * 0.25, w, h * 0.50)

            // Fill to bottom right
            ctx.lineTo(w, h)
            ctx.lineTo(0, h)
            ctx.closePath()

            // Smooth multi-stop lighting gradient across the dome
            var grad = ctx.createRadialGradient(w * 0.88, h * 0.62, 40, w * 0.72, h * 0.48, w * 0.58)
            grad.addColorStop(0.0, "#ffb82e")
            grad.addColorStop(0.20, "#f97316")
            grad.addColorStop(0.55, "#c2410c")
            grad.addColorStop(0.80, "#9a1d00")
            grad.addColorStop(1.0, "#5a0e00")

            ctx.fillStyle = grad
            ctx.fill()

            // 4. Subtle satin edge sheen on top boundary
            var sheenGrad = ctx.createLinearGradient(w * 0.38, h * 0.62, w * 0.75, h * 0.035)
            sheenGrad.addColorStop(0.0, "rgba(255, 180, 60, 0.0)")
            sheenGrad.addColorStop(0.5, "rgba(255, 200, 100, 0.15)")
            sheenGrad.addColorStop(1.0, "rgba(255, 220, 140, 0.25)")

            ctx.lineWidth = 1.8
            ctx.strokeStyle = sheenGrad
            ctx.stroke()

            ctx.restore()
        }

        Connections {
            target: root
            function onWidthChanged() { waveCanvas.requestPaint() }
            function onHeightChanged() { waveCanvas.requestPaint() }
        }
    }

    // FastBlur directly targeting the active image or procedural canvas
    FastBlur {
        id: blurEffect
        anchors.fill: parent
        source: root.customWallpaper !== "" ? bgImg : waveCanvas
        radius: root.blurRadius
        visible: root.blurRadius > 0
        transparentBorder: false
    }

    // Subtle vignette / dark overlay to keep UI elements crisp and high contrast
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.16)
        visible: root.blurRadius > 0
    }
}
