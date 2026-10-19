import QtQuick

// Small outline icons drawn in code so they can take any colour.
Canvas {
    id: glyph

    property string kind: "cpu"   // cpu, ram, temp, gauge, disk, monitor
    property color color: "#ffffff"

    implicitWidth: 36
    implicitHeight: 36

    onKindChanged: requestPaint()
    onColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    function rr(ctx, x, y, w, h, r) {
        ctx.beginPath()
        ctx.moveTo(x + r, y)
        ctx.lineTo(x + w - r, y)
        ctx.arcTo(x + w, y, x + w, y + r, r)
        ctx.lineTo(x + w, y + h - r)
        ctx.arcTo(x + w, y + h, x + w - r, y + h, r)
        ctx.lineTo(x + r, y + h)
        ctx.arcTo(x, y + h, x, y + h - r, r)
        ctx.lineTo(x, y + r)
        ctx.arcTo(x, y, x + r, y, r)
        ctx.closePath()
    }

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        var s = Math.min(width, height)
        var u = s / 36            // everything below is drawn on a 36-unit grid
        ctx.scale(u, u)
        ctx.lineWidth = 2
        ctx.lineCap = "round"
        ctx.lineJoin = "round"
        ctx.strokeStyle = color
        ctx.fillStyle = color

        if (kind === "cpu") {
            rr(ctx, 8, 8, 20, 20, 3); ctx.stroke()
            rr(ctx, 13, 13, 10, 10, 1.5); ctx.stroke()
            for (var i = 0; i < 3; i++) {
                var p = 12 + i * 6
                ctx.beginPath(); ctx.moveTo(p, 3); ctx.lineTo(p, 8); ctx.stroke()
                ctx.beginPath(); ctx.moveTo(p, 28); ctx.lineTo(p, 33); ctx.stroke()
                ctx.beginPath(); ctx.moveTo(3, p); ctx.lineTo(8, p); ctx.stroke()
                ctx.beginPath(); ctx.moveTo(28, p); ctx.lineTo(33, p); ctx.stroke()
            }
        } else if (kind === "ram") {
            rr(ctx, 4, 8, 28, 17, 2.5); ctx.stroke()
            for (var k = 0; k < 4; k++)
                ctx.fillRect(8 + k * 6, 13, 3, 7)
            for (var m = 0; m < 5; m++) {
                ctx.beginPath(); ctx.moveTo(7 + m * 5.5, 25); ctx.lineTo(7 + m * 5.5, 30); ctx.stroke()
            }
        } else if (kind === "temp") {
            rr(ctx, 14, 4, 8, 20, 4); ctx.stroke()
            ctx.beginPath(); ctx.arc(18, 27, 5.5, 0, Math.PI * 2); ctx.fill()
            ctx.beginPath(); ctx.moveTo(18, 12); ctx.lineTo(18, 26); ctx.stroke()
            ctx.beginPath(); ctx.moveTo(25, 9); ctx.lineTo(29, 9); ctx.stroke()
            ctx.beginPath(); ctx.moveTo(25, 14); ctx.lineTo(28, 14); ctx.stroke()
        } else if (kind === "gauge") {
            ctx.beginPath(); ctx.arc(18, 20, 14, Math.PI * 0.8, Math.PI * 2.2); ctx.stroke()
            ctx.beginPath(); ctx.moveTo(18, 20); ctx.lineTo(26, 11); ctx.stroke()
            ctx.beginPath(); ctx.arc(18, 20, 2.2, 0, Math.PI * 2); ctx.fill()
            for (var t = 0; t < 5; t++) {
                var a = Math.PI * (0.95 + t * 0.275)
                ctx.beginPath()
                ctx.moveTo(18 + Math.cos(a) * 10.5, 20 + Math.sin(a) * 10.5)
                ctx.lineTo(18 + Math.cos(a) * 12.5, 20 + Math.sin(a) * 12.5)
                ctx.stroke()
            }
        } else if (kind === "disk") {
            rr(ctx, 4, 9, 28, 18, 3); ctx.stroke()
            ctx.beginPath(); ctx.moveTo(4, 20); ctx.lineTo(32, 20); ctx.stroke()
            ctx.beginPath(); ctx.arc(26.5, 23.7, 1.4, 0, Math.PI * 2); ctx.fill()
            ctx.beginPath(); ctx.moveTo(9, 23.7); ctx.lineTo(18, 23.7); ctx.stroke()
        } else if (kind === "monitor") {
            rr(ctx, 5, 7, 26, 17, 2.5); ctx.stroke()
            ctx.beginPath(); ctx.moveTo(14, 30); ctx.lineTo(22, 30); ctx.stroke()
            ctx.beginPath(); ctx.moveTo(18, 24); ctx.lineTo(18, 30); ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(9, 17); ctx.lineTo(13, 17); ctx.lineTo(15.5, 12); ctx.lineTo(19, 20); ctx.lineTo(21.5, 15); ctx.lineTo(27, 15)
            ctx.stroke()
        }
    }
}
