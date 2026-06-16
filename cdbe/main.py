#!/usr/bin/env python3
"""cdbe.py — Commit Database Editor (QML port).

QML equivalent of the cdbe.py CLI in dsviper-tools.
Uses CommitStore singleton instead of direct Database access.
Adds undo/redo, commit navigation (forward, merge heads).

Run:
    python3 main.py [database.cdb]
"""
import os
import sys
from pathlib import Path

# Add project root so dsviper_components_qml is importable, and script dir for local models
sys.path.insert(0, str(Path(__file__).parent.parent))
sys.path.insert(0, str(Path(__file__).parent))

os.environ["QT_QUICK_CONTROLS_STYLE"] = "Fusion"

from PySide6.QtCore import QUrl
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine

from dsviper_components_qml.commit_store_manager import CommitStoreManager
from dsviper_components_qml.commit_admin_model import CommitAdminModel
from dsviper_components_qml.documents_panel_model import DocumentsPanelModel
from dsviper_components_qml.license_model import LicenseModel
from _version import __version__
from dsviper_components_qml.about_qt_helper import AboutQtHelper
from dsviper_components_qml.bootstrap import bootstrap_database
from dsviper_components_qml import register_qml_types


def main():
    app = QApplication(sys.argv)
    app.setOrganizationName("DigitalSubstrate")
    app.setApplicationName("CDBEditor")
    app.setApplicationVersion(__version__)
    from PySide6.QtGui import QIcon
    app.setWindowIcon(QIcon(str(Path(__file__).parent / "images" / "app_icon.png")))
    engine = QQmlApplicationEngine()

    # Core: create store and manager
    from dsviper import CommitStore
    store = CommitStore()
    mgr = CommitStoreManager(store)

    # Commit admin — black box, owns notifier setup + settings + undo/actions/program/commits/live/blobs/inspect
    commit_admin = CommitAdminModel(mgr, app, store)
    commit_admin.registerContextProperties(engine)

    # Documents panel — black box, owns abstraction/key/document/nav
    documents_panel = DocumentsPanelModel(mgr, commit_mode=True)
    documents_panel.registerContextProperties(engine)

    # Expose to QML
    ctx = engine.rootContext()
    ctx.setContextProperty("storeMgr", mgr)
    license_model = LicenseModel("CDB Editor", "Commit Database Editor for Digital Substrate databases", version=__version__)
    ctx.setContextProperty("licenseModel", license_model)
    about_qt_helper = AboutQtHelper()
    ctx.setContextProperty("aboutQtHelper", about_qt_helper)
    ctx.setContextProperty("appPid", os.getpid())

    # Python Editor model
    from dsviper_components_qml.python_editor_model import PythonEditorModel
    scripts_folder = str(Path(__file__).parent / "scripts")
    python_editor_model = PythonEditorModel(scripts_folder, namespace_vars={
        "store": mgr._store,
        "store_mgr": mgr,
        "_documents_panel": documents_panel,
    })
    ctx.setContextProperty("pythonEditorModel", python_editor_model)

    register_qml_types()
    engine.load(QUrl.fromLocalFile(str(Path(__file__).parent / "Main.qml")))
    if not engine.rootObjects():
        return 1

    from dsviper_components_qml.settings_manager import SettingsManager
    bootstrap_database(mgr, SettingsManager.instance())

    # Run main_init.py
    python_editor_model.runInitScript()

    result = app.exec()
    del engine
    return result


if __name__ == "__main__":
    sys.exit(main())
