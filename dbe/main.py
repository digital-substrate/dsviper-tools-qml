#!/usr/bin/env python3
"""dbe.py — Database Editor (QML port).

QML equivalent of the dbe.py CLI in dsviper-tools.
Opens a real dsviper Database and displays its content dynamically
based on definitions (concepts, clubs, attachments).

Run:
    python3 main.py [database.rap]
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

from dsviper_components_qml.database_manager import DatabaseManager
from dsviper_components_qml.blob_model import BlobModel
from dsviper_components_qml.documents_panel_model import DocumentsPanelModel
from dsviper_components_qml.license_model import LicenseModel
from dsviper_components_qml.about_qt_helper import AboutQtHelper
from dsviper_components_qml.bootstrap import bootstrap_database


def main():
    app = QApplication(sys.argv)
    app.setOrganizationName("DigitalSubstrate")
    app.setApplicationName("DBEditor")
    from PySide6.QtGui import QIcon
    app.setWindowIcon(QIcon(str(Path(__file__).parent / "images" / "app_icon.png")))
    engine = QQmlApplicationEngine()

    # Core: database manager owns the connection
    db_manager = DatabaseManager()

    # Documents panel — black box, owns its models internally
    documents_panel = DocumentsPanelModel(db_manager)
    documents_panel.registerContextProperties(engine)

    # Other models
    blob_model = BlobModel(db_manager)

    from dsviper_components_qml.inspect_model import InspectModel
    inspect_model = InspectModel()

    def _push_inspect_open():
        db = db_manager.database
        m = inspect_model
        m.set_path(db.path())
        m.set_documentation(db.documentation())
        m.set_uuid(db.uuid().encoded())
        m.set_codec_name(db.codec_name())
        m.set_definitions_hexdigest(db.definitions_hexdigest())
        m.set_definitions(db.definitions())

    db_manager.databaseOpened.connect(_push_inspect_open)
    db_manager.databaseClosed.connect(inspect_model.clear)

    # Expose to QML
    ctx = engine.rootContext()
    ctx.setContextProperty("dbManager", db_manager)
    ctx.setContextProperty("blobModel", blob_model)
    ctx.setContextProperty("inspectModel", inspect_model)
    license_model = LicenseModel("Database Editor", "Database Editor for Digital Substrate databases")
    ctx.setContextProperty("licenseModel", license_model)
    about_qt_helper = AboutQtHelper()
    ctx.setContextProperty("aboutQtHelper", about_qt_helper)
    ctx.setContextProperty("appPid", os.getpid())

    from dsviper_components_qml.settings_manager import SettingsManager
    settings_mgr = SettingsManager.instance()
    db_manager.setSettingsManager(settings_mgr)
    ctx.setContextProperty("settingsMgr", settings_mgr)

    engine.load(QUrl.fromLocalFile(str(Path(__file__).parent / "Main.qml")))
    if not engine.rootObjects():
        return 1

    bootstrap_database(db_manager, settings_mgr)

    result = app.exec()
    del engine
    return result


if __name__ == "__main__":
    sys.exit(main())
