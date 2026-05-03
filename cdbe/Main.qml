import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import "../dsviper_components_qml/qml" as DS

/**
 * cdbe.py QML Port — Commit Database Editor
 *
 * Uses shared DSDocumentsPanel as central widget.
 * App-specific: menus, commit toolbar, undo/redo, live mode, admin dialogs.
 */
ApplicationWindow {
    id: root
    visible: true
    width: 1000
    height: 700
    title: storeMgr.isOpen
           ? "CDB Editor (QML) — %1 — %2".arg(storeMgr.fileName).arg(appPid)
           : "CDB Editor (QML) — %1".arg(appPid)
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
                enabled: !liveModel.liveEnabled
                onTriggered: storeMgr.openDatabaseDialog()
            }
            Action {
                text: "&Close Database"
                shortcut: "Ctrl+W"
                enabled: storeMgr.isOpen && !liveModel.liveEnabled
                onTriggered: storeMgr.closeDatabase()
            }
            DS.DSMenuSeparator {}
            Action {
                text: "&Get Info"
                shortcut: "Ctrl+I"
                enabled: storeMgr.isOpen
                onTriggered: inspectDialog.visible = !inspectDialog.visible
            }
            DS.DSMenuSeparator {}
            Action {
                text: "&Forward"
                enabled: storeMgr.isOpen && !liveModel.liveEnabled
                onTriggered: storeMgr.forward()
            }
            Action {
                text: "&Merge Heads"
                enabled: storeMgr.isOpen && !liveModel.liveEnabled
                onTriggered: storeMgr.reduceHeads()
            }
            DS.DSMenuSeparator {}
            Action {
                text: "Fetc&h"
                enabled: storeMgr.isOpen && settingsMgr.hasSourceOfSync && !liveModel.liveEnabled
                onTriggered: liveModel.synchronize("fetch")
            }
            Action {
                text: "&Push"
                enabled: storeMgr.isOpen && settingsMgr.hasSourceOfSync && !liveModel.liveEnabled
                onTriggered: liveModel.synchronize("push")
            }
            Action {
                text: "&Sync"
                enabled: storeMgr.isOpen && settingsMgr.hasSourceOfSync && !liveModel.liveEnabled
                onTriggered: liveModel.synchronize("sync")
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
            title: "&Edit"
            Action {
                text: "&Undo"
                shortcut: StandardKey.Undo
                enabled: storeMgr.canUndo
                onTriggered: storeMgr.undo()
            }
            Action {
                text: "&Redo"
                shortcut: StandardKey.Redo
                enabled: storeMgr.canRedo
                onTriggered: storeMgr.redo()
            }
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

        // Editor menu
        Menu {
            title: "&Editor"
            Action {
                text: "Open Script"
                shortcut: "Ctrl+Shift+O"
                onTriggered: scriptOpenDialog.open()
            }
            Action {
                text: "Save Script"
                shortcut: "Ctrl+S"
                onTriggered: pythonEditorModel.saveSource(codeEditor.text)
            }
            DS.DSMenuSeparator {}
            Menu {
                title: "Find"
                Action {
                    text: "Find..."
                    shortcut: "Ctrl+F"
                    onTriggered: codeEditor.showFind()
                }
                Action {
                    text: "Find Next"
                    shortcut: "Ctrl+G"
                    onTriggered: codeEditor.findNext()
                }
                Action {
                    text: "Find Previous"
                    shortcut: "Ctrl+Shift+G"
                    onTriggered: codeEditor.findPrevious()
                }
                Action {
                    text: "Use Selection for Find"
                    shortcut: "Ctrl+E"
                    onTriggered: codeEditor.useSelectionForFind()
                }
                Action {
                    text: "Find and Replace..."
                    shortcut: "Ctrl+Alt+F"
                    onTriggered: codeEditor.showReplace()
                }
            }
            Action {
                text: "Jump to Next Error"
                shortcut: "Ctrl+'"
                onTriggered: pythonEditorModel.nextError()
            }
            Action {
                text: "Jump to Previous Error"
                shortcut: "Ctrl+Shift+'"
                onTriggered: pythonEditorModel.previousError()
            }
            Action {
                text: "Jump to Line"
                shortcut: "Ctrl+L"
                onTriggered: codeEditor.jumpToLine()
            }
            Action {
                text: "Jump to Definition"
                shortcut: "Ctrl+Alt+J"
                onTriggered: codeEditor.jumpToDefinition()
            }
            DS.DSMenuSeparator {}
            Action {
                text: "Run Script"
                shortcut: "Ctrl+R"
                onTriggered: pythonEditorModel.evalBuffer(codeEditor.text)
            }
            Action {
                text: "Eval"
                shortcut: "Ctrl+Return"
                onTriggered: pythonEditorModel.evalSelection(codeEditor.text, codeEditor.selectionStart, codeEditor.selectionEnd)
            }
            DS.DSMenuSeparator {}
            Action {
                text: "Show Help"
                shortcut: "Ctrl+Shift+H"
                onTriggered: pythonEditorModel.showHelp(codeEditor.expressionUnderCursor())
            }
            Action {
                text: "Show Type"
                shortcut: "Ctrl+T"
                onTriggered: pythonEditorModel.showType(codeEditor.expressionUnderCursor())
            }
            Action {
                text: "Show Description"
                onTriggered: pythonEditorModel.showDescription(codeEditor.expressionUnderCursor())
            }
            DS.DSMenuSeparator {}
            Action {
                text: "Bigger Font"
                shortcut: "Ctrl+="
                onTriggered: codeEditor.biggerFont()
            }
            Action {
                text: "Smaller Font"
                shortcut: "Ctrl+-"
                onTriggered: codeEditor.smallerFont()
            }
            DS.DSMenuSeparator {}
            Action {
                text: "Comment Selection"
                shortcut: "Ctrl+/"
                onTriggered: codeEditor.commentSelection()
            }
            Action {
                text: "Shift Right"
                shortcut: "Ctrl+]"
                onTriggered: codeEditor.shiftRight()
            }
            Action {
                text: "Shift Left"
                shortcut: "Ctrl+["
                onTriggered: codeEditor.shiftLeft()
            }
            Action {
                text: "Move Line Up"
                shortcut: "Ctrl+Alt+["
                onTriggered: codeEditor.moveLineUp()
            }
            Action {
                text: "Move Line Down"
                shortcut: "Ctrl+Alt+]"
                onTriggered: codeEditor.moveLineDown()
            }
            DS.DSMenuSeparator {}
            Action {
                text: "Refresh Syntax Coloring"
                shortcut: "Ctrl+Alt+Return"
                onTriggered: codeEditor.refreshSyntax()
            }
        }

        Menu {
            title: "&Admin"
            Action {
                text: "&Commits"
                shortcut: "Ctrl+1"
                onTriggered: commitsDialog.visible = !commitsDialog.visible
            }
            Action {
                text: "&Program"
                shortcut: "Ctrl+3"
                onTriggered: programDialog.visible = !programDialog.visible
            }
            Action {
                text: "Commit &Settings Panel"
                shortcut: "Ctrl+4"
                onTriggered: { liveModel.stopLive(); settingsDialog.visible = !settingsDialog.visible }
            }
            Action {
                text: "&Undo Stack"
                shortcut: "Ctrl+5"
                onTriggered: undoDialog.visible = !undoDialog.visible
            }
            Action {
                text: "Sync &Log"
                shortcut: "Ctrl+6"
                onTriggered: syncLogDialog.visible = !syncLogDialog.visible
            }
            Action {
                text: "&Blobs"
                shortcut: "Ctrl+7"
                onTriggered: blobsDialog.visible = !blobsDialog.visible
            }
            Action {
                text: "&Actions"
                shortcut: "Ctrl+8"
                onTriggered: actionsDialog.visible = !actionsDialog.visible
            }
            DS.DSMenuSeparator {}
            Action {
                text: "Python &Editor"
                shortcut: "Ctrl+0"
                onTriggered: codeEditorWindow.visible = !codeEditorWindow.visible
            }
            DS.DSMenuSeparator {}
            Action {
                text: "Connect To Server"
                shortcut: "Ctrl+K"
                onTriggered: connectDialog.open()
            }
        }
        Menu {
            title: "&Help"
            MenuItem {
                text: "\u200BAbout CDB Editor..."
                onTriggered: aboutDialog.open()
            }
            MenuItem {
                text: "\u200BAbout Qt"
                onTriggered: aboutQtHelper.showAboutQt()
            }
        }
    }

    // Toolbar
    header: ToolBar {
        background: Rectangle { color: DS.DSTheme.window }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            spacing: 4

            // Commit operations — shared toolbar (Forward, Merge Heads, Fetch/Push/Sync, Manager, Go Live)
            DS.CommitToolBar {}

            Item { width: 8 }

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

    // ================================================================
    // Shared dialogs — extracted to dsviper_components_qml/qml/
    // ================================================================
    DS.BlobsDialog { id: blobsDialog }

    // Python Editor (Ctrl+0)
    Window {
        id: codeEditorWindow
        title: "Python Editor"
        width: 900; height: 600
        color: DS.DSTheme.window
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
        flags: Qt.Window

        DS.CodeEditor {
            id: codeEditor
            anchors.fill: parent
            editorModel: pythonEditorModel
        }
    }
    FileDialog {
        id: scriptOpenDialog
        title: "Open Script"
        currentFolder: "file://" + pythonEditorModel.scriptsFolder()
        nameFilters: ["Python files (*.py)", "All files (*)"]
        onAccepted: pythonEditorModel.openScript(selectedFile)
    }

    DS.UndoDialog { id: undoDialog }
    DS.SyncLogDialog { id: syncLogDialog }
    DS.ActionsDialog { id: actionsDialog }
    DS.CommitSettingsDialog { id: settingsDialog }
    DS.ProgramDialog { id: programDialog }
    DS.CommitsDialog { id: commitsDialog }
    DS.ConnectDialog { id: connectDialog }
    DS.ErrorDialog { id: errorDialog }
    DS.AboutDialog { id: aboutDialog; model: licenseModel }
    DS.LicenseDialog { id: licenseDialog; model: licenseModel }
}
