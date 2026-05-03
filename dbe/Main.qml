import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../dsviper_components_qml/qml" as DS

/**
 * dbe.py QML Port — Database Editor
 *
 * Uses shared DSDocumentsPanel as central widget.
 * App-specific: menus, toolbar, inspect/blobs dialogs.
 */
ApplicationWindow {
    id: root
    visible: true
    width: 1000
    height: 700
    title: dbManager.isOpen
           ? "Database Editor (QML) — %1 — %2".arg(dbManager.fileName).arg(appPid)
           : "Database Editor (QML) — %1".arg(appPid)
    color: DS.DSTheme.window
    font.pixelSize: 12

    palette {
        window: DS.DSTheme.window
        windowText: DS.DSTheme.windowText
        base: DS.DSTheme.base
        alternateBase: DS.DSTheme.alternateBase
        text: DS.DSTheme.text
        button: DS.DSTheme.button
        buttonText: DS.DSTheme.buttonText
        highlight: DS.DSTheme.highlight
        highlightedText: DS.DSTheme.highlightedText
        mid: DS.DSTheme.mid
        midlight: DS.DSTheme.midlight
        light: DS.DSTheme.light
        dark: DS.DSTheme.dark
        placeholderText: DS.DSTheme.placeholderText
        toolTipBase: DS.DSTheme.toolTipBase
        toolTipText: DS.DSTheme.toolTipText
    }

    menuBar: MenuBar {
        Menu {
            title: "&File"
            Action {
                text: "&Open Database..."
                shortcut: "Ctrl+O"
                onTriggered: dbManager.openDatabaseDialog()
            }
            Action {
                text: "&Close Database"
                shortcut: "Ctrl+W"
                enabled: dbManager.isOpen
                onTriggered: dbManager.closeDatabase()
            }
            DS.DSMenuSeparator {}
            Action {
                text: "&Get Info"
                shortcut: "Ctrl+I"
                enabled: dbManager.isOpen
                onTriggered: inspectDialog.visible = !inspectDialog.visible
            }
            Action {
                text: "Get &Blobs"
                shortcut: "Ctrl+7"
                enabled: dbManager.isOpen
                onTriggered: blobsDialog.visible = !blobsDialog.visible
            }
            DS.DSMenuSeparator {}
            Action {
                text: "Reopen Last Database"
                checkable: true
                checked: settingsMgr.reopenLastFile
                onTriggered: settingsMgr.reopenLastFile = checked
            }
            DS.DSMenuSeparator {}
            Action { text: "&Quit"; shortcut: "Ctrl+Q"; onTriggered: Qt.quit() }
        }
        Menu {
            title: "&Navigation"
            Action {
                text: "Go &Forward"
                shortcut: "Ctrl+Shift+Right"
                enabled: navController.canGoForward
                onTriggered: navController.goForward()
            }
            Action {
                text: "Go &Back"
                shortcut: "Ctrl+Shift+Left"
                enabled: navController.canGoBack
                onTriggered: navController.goBack()
            }
        }
        Menu {
            title: "&Help"
            MenuItem {
                text: "\u200BAbout Database Editor..."
                onTriggered: aboutDialog.open()
            }
            MenuItem {
                text: "\u200BAbout Qt"
                onTriggered: aboutQtHelper.showAboutQt()
            }
        }
    }

    // Toolbar with navigation + feedback
    header: ToolBar {
        background: Rectangle { color: DS.DSTheme.window }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            spacing: 4

            Label {
                id: feedbackLabel
                color: DS.DSTheme.error
                text: ""
                opacity: 0

                OpacityAnimator on opacity {
                    id: feedbackFadeOut
                    from: 1.0; to: 0.0
                    duration: 2000
                    running: false
                }
            }
            Item { Layout.fillWidth: true }
        }
    }

    // Central widget — shared documents panel
    DS.DocumentsPanel {
        anchors.fill: parent

        onValidationFailed: function(row, expectedType) {
            feedbackLabel.text = "Row %1: invalid value for type '%2'".arg(row).arg(expectedType)
            feedbackLabel.opacity = 1.0
            feedbackFadeOut.start()
        }
    }

    DS.InspectDialog { id: inspectDialog }

    DS.BlobsDialog { id: blobsDialog }

    DS.AboutDialog { id: aboutDialog; model: licenseModel }
    DS.LicenseDialog { id: licenseDialog; model: licenseModel }
}
