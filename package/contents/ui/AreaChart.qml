import QtQuick

// Filled line chart of the most recent samples, newest on the right.
Canvas {
    id: chart

    property var values: []
    property int capacity: 40
    property real maxValue: 100
    property color lineColor: "#2ea8ff"

    onValuesChanged: requestPaint()
    onCapacityChanged: requestPaint()
    onLineColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    function rgba(c, a) {
        return "rgba(" + Math.round(c.r * 255) + "," + Math.round(c.g * 255) + "," + Math.round(c.b * 255) + "," + a + ")"
    }

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        var n = values.length
        if (n < 2 || width <= 0 || height <= 0)
            return
        var step = width / Math.max(1, capacity - 1)
        var pad = 2
        var h = height - pad * 2

        function px(i) { return width - (n - 1 - i) * step }
        function py(i) {
            var v = Math.max(0, Math.min(maxValue, values[i]))
            return pad + h - (v / maxValue) * h
        }

        ctx.beginPath()
        ctx.moveTo(px(0), height)
        for (var i = 0; i < n; i++)
            ctx.lineTo(px(i), py(i))
        ctx.lineTo(px(n - 1), height)
        ctx.closePath()
        var grad = ctx.createLinearGradient(0, 0, 0, height)
        grad.addColorStop(0, rgba(lineColor, 0.55))
        grad.addColorStop(1, rgba(lineColor, 0.04))
        ctx.fillStyle = grad
        ctx.fill()

        ctx.beginPath()
        for (var j = 0; j < n; j++) {
            if (j === 0)
                ctx.moveTo(px(j), py(j))
            else
                ctx.lineTo(px(j), py(j))
        }
        ctx.lineWidth = 1.5
        ctx.lineJoin = "round"
        ctx.strokeStyle = rgba(lineColor, 1.0)
        ctx.stroke()
    }
}
