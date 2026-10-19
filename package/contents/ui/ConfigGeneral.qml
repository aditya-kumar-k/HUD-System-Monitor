import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    property string cfg_title
    property string cfg_titleDefault: "System Monitor"
    property int cfg_updateInterval
    property int cfg_updateIntervalDefault: 1
    property int cfg_historyPoints
    property int cfg_historyPointsDefault: 40
    property string cfg_diskId
    property string cfg_diskIdDefault: "disk/all"
    property bool cfg_showHeader
    property bool cfg_showHeaderDefault: true
    property int cfg_tempWarning
    property int cfg_tempWarningDefault: 85
    // Set by Plasma on every page for panel-capable widgets
    property bool cfg_expanding
    property bool cfg_expandingDefault: false
    property int cfg_length
    property int cfg_lengthDefault: 0

    Kirigami.FormLayout {
        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Header:")
            text: i18n("Show icon, title and menu")
            checked: page.cfg_showHeader
            onToggled: page.cfg_showHeader = checked
        }

        QQC2.TextField {
            Kirigami.FormData.label: i18n("Title:")
            enabled: page.cfg_showHeader
            text: page.cfg_title
            onTextEdited: page.cfg_title = text
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Update every:")
            from: 1
            to: 10
            value: page.cfg_updateInterval
            onValueModified: page.cfg_updateInterval = value
            textFromValue: function (v) { return i18n("%1 s", v) }
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Chart history:")
            from: 10
            to: 200
            stepSize: 5
            value: page.cfg_historyPoints
            onValueModified: page.cfg_historyPoints = value
            textFromValue: function (v) { return i18n("%1 samples", v) }
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Temperature warning:")
            from: 40
            to: 120
            value: page.cfg_tempWarning
            onValueModified: page.cfg_tempWarning = value
            textFromValue: function (v) { return v + " °C" }
        }

        QQC2.TextField {
            Kirigami.FormData.label: i18n("Disk sensor:")
            text: page.cfg_diskId
            placeholderText: "disk/all"
            onTextEdited: page.cfg_diskId = text
        }

        QQC2.Label {
            text: i18n("Use disk/all for every drive together, or a volume such as disk/<uuid>. Run \"kstatsviewer --list | grep disk/\" to see the options.")
            wrapMode: Text.WordWrap
            opacity: 0.7
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
        }
    }
}
