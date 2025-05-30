import sys
import darkdetect
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QToolBar, QListWidget,
    QLabel, QGraphicsView, QVBoxLayout, QWidget, QSplitter
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QPalette, QColor


class InstrunatorGUI(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Instrunator")
        self.setGeometry(100, 100, 1200, 800)
        self.set_dark_mode(darkdetect.isDark())
        
        # --- Toolbar ---
        toolbar = QToolBar("Tools")
        self.addToolBar(Qt.ToolBarArea.TopToolBarArea, toolbar)

        # --- Sidebar (Instruments) ---
        instruments = QListWidget()
        instruments.addItems(["Ramp Generator", "Lock-in", "PID", "Multimeter"])
        instruments.setMinimumWidth(180)

        sidebar_container = QWidget()
        sidebar_layout = QVBoxLayout(sidebar_container)
        sidebar_layout.setContentsMargins(4, 4, 4, 4)
        sidebar_layout.addWidget(QLabel("Instruments"))
        sidebar_layout.addWidget(instruments)

        # --- Node Editor Area ---
        node_editor = QGraphicsView()
        node_editor_label = QLabel("Node Editor")
        node_editor_label.setAlignment(Qt.AlignmentFlag.AlignCenter)

        node_editor_container = QWidget()
        node_layout = QVBoxLayout(node_editor_container)
        node_layout.setContentsMargins(4, 4, 4, 4)
        node_layout.addWidget(node_editor_label)
        node_layout.addWidget(node_editor)

        # --- Split Layout ---
        splitter = QSplitter(Qt.Orientation.Horizontal)
        splitter.addWidget(sidebar_container)
        splitter.addWidget(node_editor_container)
        splitter.setStretchFactor(1, 1)

        self.setCentralWidget(splitter)

    def set_dark_mode(self, enable_dark: bool):
        palette = QPalette()
        if enable_dark:
            palette.setColor(QPalette.ColorRole.Window, QColor("#121212"))
            palette.setColor(QPalette.ColorRole.WindowText, Qt.GlobalColor.white)
            palette.setColor(QPalette.ColorRole.Base, QColor("#1e1e1e"))
            palette.setColor(QPalette.ColorRole.AlternateBase, QColor("#121212"))
            palette.setColor(QPalette.ColorRole.ToolTipBase, Qt.GlobalColor.white)
            palette.setColor(QPalette.ColorRole.ToolTipText, Qt.GlobalColor.white)
            palette.setColor(QPalette.ColorRole.Text, Qt.GlobalColor.white)
            palette.setColor(QPalette.ColorRole.Button, QColor("#2b2b2b"))
            palette.setColor(QPalette.ColorRole.ButtonText, Qt.GlobalColor.white)
            palette.setColor(QPalette.ColorRole.BrightText, Qt.GlobalColor.red)
        else:
            palette = QApplication.style().standardPalette()

        QApplication.setPalette(palette)


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = InstrunatorGUI()
    window.show()
    sys.exit(app.exec())
