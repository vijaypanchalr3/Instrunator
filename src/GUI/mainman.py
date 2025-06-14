# main_window.py
from PyQt6.QtWidgets import QMainWindow, QToolBar, QSplitter
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QAction

from sideman import Sidebar
from nodeman import NodeMan
# from theme import apply_system_theme

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Instrunator")
        self.setGeometry(100, 100, 1200, 800)

        # apply_system_theme()

        # --- Toolbar ---
        toolbar = QToolBar("Tools")
        self.addToolBar(Qt.ToolBarArea.TopToolBarArea, toolbar)

        # Add collapse action
        self.toggle_sidebar_action = QAction("Toggle Sidebar", self)
        self.toggle_sidebar_action.triggered.connect(self.toggle_sidebar)
        toolbar.addAction(self.toggle_sidebar_action)

        # --- Split Layout ---
        self.splitter = QSplitter(Qt.Orientation.Horizontal)
        self.sidebar = Sidebar()
        self.editor = NodeMan()
        self.splitter.addWidget(self.sidebar)
        self.splitter.addWidget(self.editor)
        self.splitter.setStretchFactor(1, 1)
        self.setCentralWidget(self.splitter)

        # Track state
        self.sidebar_visible = True

    def toggle_sidebar(self):
        if self.sidebar_visible:
            self.splitter.setSizes([0, 1])
        else:
            self.splitter.setSizes([200, 1])
        self.sidebar_visible = not self.sidebar_visible
