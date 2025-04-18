import sys
from PyQt6.QtWidgets import (
    QApplication, QWidget, QLabel, QVBoxLayout, QPushButton,
    QHBoxLayout, QLineEdit, QTextEdit, QDoubleSpinBox, QSpinBox
)
from PyQt6.QtCore import Qt

# Replace these with actual MATLAB/Python backend function calls
def run_rvg(voltage: float):
    print(f"[Instrunator] Setting RVg to {voltage} V")

def run_measurement():
    print("[Instrunator] Running measurement...")

def start_sampler(repetitions: int):
    print(f"[Instrunator] Starting sampler with {repetitions} repetitions")

class InstrunatorGUI(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Instrunator Control Panel")
        self.setFixedSize(400, 300)
        self.setup_ui()

    def setup_ui(self):
        layout = QVBoxLayout()

        # Voltage Control
        voltage_layout = QHBoxLayout()
        voltage_label = QLabel("Set Voltage (V):")
        self.voltage_input = QDoubleSpinBox()
        self.voltage_input.setRange(-10.0, 10.0)
        self.voltage_input.setDecimals(3)
        self.voltage_input.setSingleStep(0.01)
        voltage_btn = QPushButton("Apply Voltage")
        voltage_btn.clicked.connect(self.apply_voltage)
        voltage_layout.addWidget(voltage_label)
        voltage_layout.addWidget(self.voltage_input)
        voltage_layout.addWidget(voltage_btn)
        layout.addLayout(voltage_layout)

        # Measurement Button
        measure_btn = QPushButton("Run Measurement")
        measure_btn.clicked.connect(self.run_measurement)
        layout.addWidget(measure_btn)

        # Sampler Control
        sampler_layout = QHBoxLayout()
        self.rep_input = QSpinBox()
        self.rep_input.setRange(1, 1000)
        sampler_btn = QPushButton("Start Sampler")
        sampler_btn.clicked.connect(self.start_sampler)
        sampler_layout.addWidget(QLabel("Repetitions:"))
        sampler_layout.addWidget(self.rep_input)
        sampler_layout.addWidget(sampler_btn)
        layout.addLayout(sampler_layout)

        # Logger
        self.log_output = QTextEdit()
        self.log_output.setReadOnly(True)
        layout.addWidget(QLabel("Log Output:"))
        layout.addWidget(self.log_output)

        self.setLayout(layout)

    def log(self, message: str):
        self.log_output.append(f"> {message}")

    def apply_voltage(self):
        voltage = self.voltage_input.value()
        run_rvg(voltage)
        self.log(f"Voltage set to {voltage:.3f} V")

    def run_measurement(self):
        run_measurement()
        self.log("Measurement triggered.")

    def start_sampler(self):
        repetitions = self.rep_input.value()
        start_sampler(repetitions)
        self.log(f"Sampler started with {repetitions} repetitions.")

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = InstrunatorGUI()
    window.show()
    sys.exit(app.exec())
