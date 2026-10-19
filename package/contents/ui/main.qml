import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    readonly property color textColor: "#eef4f8"
    readonly property color mutedColor: "#9fb3c2"
    readonly property color cyan: "#2ea8ff"
    readonly property color purple: "#a46bff"
    readonly property color orange: "#ff8a4c"
    readonly property color red: "#ff4d4d"
    readonly property color gaugeBlue: "#3da5ff"

    readonly property int capacity: Plasmoid.configuration.historyPoints
    property var cpuHistory: []
    property var ramHistory: []

    function num(v) {
        var n = Number(v)
        return isFinite(n) ? n : 0
    }

    function gib(bytes) {
        return (num(bytes) / 1073741824).toFixed(1)
    }

    function push(arr, v) {
        var a = arr.slice()
        a.push(v)
        while (a.length > capacity)
            a.shift()
        return a
    }

    Sensors.Sensor { id: cpuUsage; sensorId: "cpu/all/usage"; updateRateLimit: 1000 }
    Sensors.Sensor { id: cpuFreq; sensorId: "cpu/all/averageFrequency"; updateRateLimit: 1000 }
    Sensors.Sensor { id: cpuTemp; sensorId: "cpu/all/maximumTemperature"; updateRateLimit: 1000 }
    Sensors.Sensor { id: ramUsed; sensorId: "memory/physical/used"; updateRateLimit: 1000 }
    Sensors.Sensor { id: ramTotal; sensorId: "memory/physical/total"; updateRateLimit: 5000 }
    Sensors.Sensor { id: diskUsed; sensorId: Plasmoid.configuration.diskId + "/used"; updateRateLimit: 10000 }
    Sensors.Sensor { id: diskTotal; sensorId: Plasmoid.configuration.diskId + "/total"; updateRateLimit: 10000 }

    readonly property real cpuPct: num(cpuUsage.value)
    readonly property real ramPct: num(ramTotal.value) > 0 ? num(ramUsed.value) / num(ramTotal.value) * 100 : 0
    readonly property real diskPct: num(diskTotal.value) > 0 ? num(diskUsed.value) / num(diskTotal.value) * 100 : 0
    readonly property bool tempHot: num(cpuTemp.value) >= Plasmoid.configuration.tempWarning

    Timer {
        interval: Math.max(1, Plasmoid.configuration.updateInterval) * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.cpuHistory = root.push(root.cpuHistory, root.cpuPct)
            root.ramHistory = root.push(root.ramHistory, root.ramPct)
        }
    }

    fullRepresentation: Item {
        id: view

        // Everything below scales with the widget; 1.0 at 432 x 256
        readonly property real u: Math.max(0.3, Math.min(width / 432, height / 256))

        Layout.minimumWidth: 180
        Layout.minimumHeight: Math.round(view.u * 110)
        Layout.preferredWidth: Math.round(view.u * 432)
        Layout.preferredHeight: Math.round(view.u * 256)

        LiquidGlassCard {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.round(view.u * 20)
            spacing: Math.round(view.u * 10)

            // Header
            RowLayout {
                visible: Plasmoid.configuration.showHeader
                Layout.fillWidth: true
                spacing: Math.round(view.u * 12)

                Rectangle {
                    Layout.preferredWidth: Math.round(view.u * 34)
                    Layout.preferredHeight: Math.round(view.u * 34)
                    radius: view.u * 17
                    color: Qt.rgba(0.18, 0.66, 1, 0.12)
                    border.width: 1.5
                    border.color: root.cyan

                    GlyphIcon {
                        anchors.centerIn: parent
                        width: Math.round(22 * view.u)
                        height: Math.round(22 * view.u)
                        kind: "monitor"
                        color: root.cyan
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: Plasmoid.configuration.title
                    color: root.textColor
                    font.pixelSize: Math.round(view.u * 18)
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Item {
                    Layout.preferredWidth: Math.round(view.u * 24)
                    Layout.preferredHeight: Math.round(view.u * 24)

                    Column {
                        anchors.centerIn: parent
                        spacing: Math.round(view.u * 3)
                        Repeater {
                            model: 3
                            Rectangle { width: 4; height: 4; radius: view.u * 2; color: root.mutedColor }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Plasmoid.internalAction("configure").trigger()
                    }
                }
            }

            Rectangle { visible: Plasmoid.configuration.showHeader; Layout.fillWidth: true; Layout.preferredHeight: 1; color: Qt.rgba(1, 1, 1, 0.12) }

            // CPU and RAM with charts
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Math.round(view.u * 14)

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    spacing: Math.round(view.u * 6)

                    RowLayout {
                        spacing: Math.round(view.u * 10)
                        GlyphIcon { kind: "cpu"; color: root.cyan; implicitWidth: Math.round(view.u * 36); implicitHeight: Math.round(view.u * 36) }
                        ColumnLayout {
                            spacing: 0
                            Text { text: i18n("CPU Usage"); color: root.mutedColor; font.pixelSize: Math.round(view.u * 13) }
                            Text {
                                text: root.cpuPct.toFixed(1) + "%"
                                color: root.textColor
                                font.pixelSize: Math.round(view.u * 24)
                                font.weight: Font.Medium
                            }
                        }
                    }

                    AreaChart {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: Math.round(view.u * 36)
                        values: root.cpuHistory
                        capacity: root.capacity
                        maxValue: 100
                        lineColor: root.cyan
                    }
                }

                Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: Qt.rgba(1, 1, 1, 0.12) }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    spacing: Math.round(view.u * 6)

                    RowLayout {
                        spacing: Math.round(view.u * 10)
                        GlyphIcon { kind: "ram"; color: root.purple; implicitWidth: Math.round(view.u * 36); implicitHeight: Math.round(view.u * 36) }
                        ColumnLayout {
                            spacing: 0
                            Text { text: i18n("RAM Usage"); color: root.mutedColor; font.pixelSize: Math.round(view.u * 13) }
                            Row {
                                spacing: Math.round(view.u * 4)
                                Text {
                                    text: root.gib(ramUsed.value)
                                    color: root.textColor
                                    font.pixelSize: Math.round(view.u * 24)
                                    font.weight: Font.Medium
                                }
                                Text {
                                    anchors.baseline: parent.children[0].baseline
                                    text: "GiB / " + root.gib(ramTotal.value) + " GiB"
                                    color: root.mutedColor
                                    font.pixelSize: Math.round(view.u * 13)
                                }
                            }
                        }
                    }

                    AreaChart {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: Math.round(view.u * 36)
                        values: root.ramHistory
                        capacity: root.capacity
                        maxValue: 100
                        lineColor: root.purple
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Qt.rgba(1, 1, 1, 0.12) }

            // Temperature, frequency, disk
            RowLayout {
                Layout.fillWidth: true
                spacing: Math.round(view.u * 12)

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    spacing: Math.round(view.u * 8)
                    GlyphIcon {
                        kind: "temp"
                        color: root.tempHot ? root.red : root.orange
                        implicitWidth: Math.round(view.u * 34)
                        implicitHeight: Math.round(view.u * 34)
                    }
                    ColumnLayout {
                        spacing: 0
                        Text {
                            text: Math.round(root.num(cpuTemp.value)) + " °C"
                            color: root.tempHot ? root.red : root.orange
                            font.pixelSize: Math.round(view.u * 22)
                            font.weight: Font.Medium
                        }
                        Text { text: i18n("CPU Temp"); color: root.mutedColor; font.pixelSize: Math.round(view.u * 12) }
                    }
                }

                Rectangle { Layout.preferredHeight: Math.round(view.u * 38); Layout.preferredWidth: 1; color: Qt.rgba(1, 1, 1, 0.12) }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    spacing: Math.round(view.u * 8)
                    GlyphIcon { kind: "gauge"; color: root.gaugeBlue; implicitWidth: Math.round(view.u * 34); implicitHeight: Math.round(view.u * 34) }
                    ColumnLayout {
                        spacing: 0
                        Row {
                            spacing: Math.round(view.u * 4)
                            Text {
                                text: (root.num(cpuFreq.value) / 1000).toFixed(1)
                                color: root.textColor
                                font.pixelSize: Math.round(view.u * 22)
                                font.weight: Font.Medium
                            }
                            Text {
                                anchors.baseline: parent.children[0].baseline
                                text: "GHz"
                                color: root.mutedColor
                                font.pixelSize: Math.round(view.u * 13)
                            }
                        }
                        Text { text: i18n("CPU Frequency"); color: root.mutedColor; font.pixelSize: Math.round(view.u * 12) }
                    }
                }

                Rectangle { Layout.preferredHeight: Math.round(view.u * 38); Layout.preferredWidth: 1; color: Qt.rgba(1, 1, 1, 0.12) }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    spacing: Math.round(view.u * 8)
                    GlyphIcon { kind: "disk"; color: root.gaugeBlue; implicitWidth: Math.round(view.u * 34); implicitHeight: Math.round(view.u * 34) }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Math.round(view.u * 2)
                        Text {
                            text: Math.round(root.diskPct) + "%"
                            color: root.textColor
                            font.pixelSize: Math.round(view.u * 20)
                            font.weight: Font.Medium
                        }
                        Text {
                            text: root.gib(diskUsed.value) + " / " + root.gib(diskTotal.value) + " GiB"
                            color: root.mutedColor
                            font.pixelSize: Math.round(view.u * 11)
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.round(view.u * 5)
                            radius: view.u * 2.5
                            color: Qt.rgba(1, 1, 1, 0.12)

                            Rectangle {
                                width: parent.width * Math.min(1, root.diskPct / 100)
                                height: parent.height
                                radius: parent.radius
                                color: root.gaugeBlue
                            }
                        }
                    }
                }
            }
        }
    }
}
