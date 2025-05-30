from PyQt6.QtWidgets import QWidget, QVBoxLayout, QLabel, QListWidget, QPushButton

class Sidebar(QWidget):
    def __init__(self):
        super().__init__()
        layout = QVBoxLayout()
        layout.setContentsMargins(4, 4, 4, 4)

        collapse_btn = QPushButton("⮜")
        collapse_btn.clicked.connect(lambda: self.parent().parent().toggle_sidebar())  # or use signal
        layout.addWidget(collapse_btn)

        layout.addWidget(QLabel("Instruments"))
        instrument_list = QListWidget()
        instrument_list.addItems(["Ramp Generator", "Lock-in", "Multimeter", "PID"])
        layout.addWidget(instrument_list)

        self.setLayout(layout)
        self.setMinimumWidth(180)
