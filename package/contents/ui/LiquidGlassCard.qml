import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

// Liquid-glass card background (refraction + chromatic aberration + specular),
// using the LiquidGlass component. Values come from the [Liquid] group of
// ~/.config/hudglassrc and are re-read every few seconds.
LiquidGlass {
    id: card

    // Defaults match the macOS-style weather widget's glass settings
    radius: 50
    roundness: 8.6
    refractThickness: 35
    refractIOR: 1.7
    refractScale: 65
    tint: "#000000"
    tintAlpha: 0.10
    chromaStrength: 0.30
    specStrength: 0.70
    blurRadius: 6
    realtimeRefraction: false

    Plasma5Support.DataSource {
        id: reader
        engine: "executable"
        connectedSources: []

        function key(name, fallback) {
            return "kreadconfig6 --file hudglassrc --group Liquid --key " + name + " --default " + fallback
        }

        readonly property string cmd: [
            key("Radius", 50), key("Roundness", 86), key("Thickness", 35), key("IOR", 170),
            key("Strength", 65), key("TintAlpha", 10), key("Chroma", 30), key("Specular", 70),
            key("Blur", 6), key("Realtime", "false"), key("TintColor", "#000000")
        ].join("; ")

        onNewData: function (source, data) {
            disconnectSource(source)
            var v = (data["stdout"] || "").split("\n")
            var num = function (i, fallback) {
                var n = parseFloat(v[i])
                return isNaN(n) ? fallback : n
            }
            card.radius = num(0, 50)
            card.roundness = num(1, 86) / 10
            card.refractThickness = num(2, 35)
            card.refractIOR = num(3, 170) / 100
            card.refractScale = num(4, 65)
            card.tintAlpha = num(5, 10) / 100
            card.chromaStrength = num(6, 30) / 100
            card.specStrength = num(7, 70) / 100
            card.blurRadius = num(8, 6)
            card.realtimeRefraction = (v[9] || "").trim() === "true"
            var tc = (v[10] || "").trim()
            if (/^#[0-9a-fA-F]{6}$/.test(tc))
                card.tint = tc
        }
        function read() { connectSource(cmd + " #" + Date.now()) }
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: reader.read()
    }
}
