import threading

from qtpynodeeditor import (NodeData, NodeDataModel, NodeDataType,
                            NodeValidationState, Port, PortType)

from numpy import float64 as npfloat64

from PyQt6.QtWidgets import QLabel

import h5py

from PyQt6.QtWidgets import QWidget, QComboBox, QHBoxLayout, QPushButton, QFileDialog, QDoubleSpinBox, QVBoxLayout

# from LED import LED

class Float64Data(NodeData):
    'Node data holding a float64 value'
    data_type = NodeDataType("float64", "Float64")

    def __init__(self, number: npfloat64 = 0.0):
        self._number = number
        self._lock = threading.RLock()

    @property
    def lock(self):
        return self._lock

    @property
    def number(self) -> npfloat64:
        'The number data'
        return self._number

    def number_as_text(self) -> str:
        'Number as a string'
        return '%g' % self._number
    
class FlagData(NodeData):
    'Node data holding a flag'
    data_type = NodeDataType("bool", "Bool")

    def __init__(self, flag: int = 0):
        self._flag = flag

    @property
    def flag(self) -> int:
        'The number data'
        return self._flag


class FileModel(NodeDataModel):
    name = 'FileModel'
    caption = 'File Model'
    caption_visible = True
    num_ports = {PortType.input: 1,
                 PortType.output: 0,
                 }
    data_type = {
        PortType.input: {
            0: Float64Data.data_type
        }
    }

    def __init__(self, style=None, parent=None):
        super().__init__(style, parent)
        self._file_path = None
        self._number = Float64Data(0.0)
        self._file_label = QLabel("No file selected")
        self.btn = QPushButton("Choose File")
        self.btn.clicked.connect(self.open_file_dialog)
        self.layout = QVBoxLayout()
        self.layout.addWidget(self.btn)
        self.layout.addWidget(self.label)
        self.setLayout(self.layout)

    def open_file_dialog(self):
        file_path, _ = QFileDialog.getOpenFileName(self, "Open File", "", "All Files (*)")
        if file_path:
            self._file_path = file_path
            self._file_label.setText(file_path)
            self.data_updated.emit(0)  # Notify that data has changed

    def save_data_async(self):
        # Start a thread to save data
        t = threading.Thread(target=self._save_data_worker)
        t.start()

    def _save_data_worker(self):
        # This runs in a background thread
        if not hasattr(self, '_file_path') or not hasattr(self, '_number'):
            return
        try:
            with h5py.File(self._file_path, 'a') as f:
                if 'data' in f:
                    dset = f['data']
                    old_size = dset.shape[0]
                    new_size = old_size + 1
                    dset.resize((new_size,))
                    dset[old_size] = self._number.number
                else:
                    f.create_dataset('data', data=[self._number.number], maxshape=(None,))
        except Exception as e:
            print(f"Error saving data: {e}")


    def out_data(self, port_index):
        return MyNodeData()

    def set_in_data(self, data: NodeData, port: Port):
        '''
        New data at the input of the node

        Parameters
        ----------
        data : NodeData
        port_index : int
        '''
        if port.index == 0:
            self._number = data

        if self._check_inputs():
            with self._compute_lock():
                self.compute()

    def compute(self):
        '''
        Save the data to a file in a background thread
        '''
        self.save_data_async()

class SourceModel(NodeDataModel):
    
    num_ports = {PortType.input: 0,
                 PortType.output: 1,
                 }
    data_type = {
        PortType.output: {
            0: Float64Data.data_type
        }
    }

    Source_list = [
        "Keithley 2400",
        "SR830 Lock-in AUX1",
        "SR830 Lock-in AUX2",
        "SR830 Lock-in AUX3",
        "SR830 Lock-in AUX4",
        "Agilent 34401A",
        "keithley B2901A"
    ]

    def __init__(self, style=None, parent=None):
        super().__init__(style, parent)
        self._source_data = Float64Data(0.0)
        self._choice = QComboBox()
        self._choice.addItems(self.Source_list)
        # self.embedded_widget()

    def embedded_widget(self):
        ...

    def out_data(self, port_index):
        return 1

    def set_in_data(self, data: NodeData, port: Port):
        if port.index == 0:
            self._source_data = data

        if self._check_inputs():
            with self._compute_lock():
                self.compute()

    def compute(self):
        ...

import time
class Keithley2400(SourceModel):
    name = 'Keithley2400'
    caption = 'Keithley 2400'
    caption_visible = True

    def __init__(self, style=None, parent=None):
        super().__init__(style, parent)
        self._source_data = Float64Data(0.0)

        self.output_flag = 0
        self.embedded_widget()

    def get_output_flag(self)->bool:
        self.output_flag = 1

    
    def embedded_widget(self):
        widget = QWidget()
        layout = QVBoxLayout()
        layout.setContentsMargins(2, 2, 2, 2)

        part1 = QHBoxLayout()
        part1.setContentsMargins(0,0,0,0)
        Output_on_label = QLabel("Output")
        # Output_on_LED = LED(self.output_flag)
        part1.addWidget(Output_on_label)
        # part1.addWidget(Output_on_LED)
        layout.addLayout(part1)



        current_limit_label = QLabel("Set Current Limit (A):")
        current_limit_label.setStyleSheet("font-size:10px;")  # Smaller font

        set_limit_btn = QPushButton("Apply Limit")
        set_limit_btn.setFixedSize(80, 20)  # Small button

        self.current_voltage_label = QLabel("Current Voltage: 0 V")
        layout.addWidget(self.current_voltage_label)

        layout.addWidget(current_limit_label)
        layout.addWidget(set_limit_btn)
        widget.setLayout(layout)
        self.voltage_spin = QDoubleSpinBox()
        self.voltage_spin.setRange(-200, 200)
        self.voltage_spin.setValue(0)
        self.step_spin = QDoubleSpinBox()
        self.step_spin.setRange(0.01, 10)
        self.step_spin.setValue(0.1)
        self.delay_spin = QDoubleSpinBox()
        self.delay_spin.setRange(0.01, 5)
        self.delay_spin.setValue(0.1)
        ramp_btn = QPushButton("Ramp to Voltage")
        ramp_btn.clicked.connect(self.start_ramp)

        layout.addWidget(QLabel("Target Voltage:"))
        layout.addWidget(self.voltage_spin)
        layout.addWidget(QLabel("Step:"))
        layout.addWidget(self.step_spin)
        layout.addWidget(QLabel("Delay:"))
        layout.addWidget(self.delay_spin)
        layout.addWidget(ramp_btn)
        widget.setLayout(layout)
        # Set minimum and maximum size for the widget
        widget.setMinimumSize(100, 50)
        # widget.setMaximumSize(300, 100)


        return widget
    def start_ramp(self):
        target = self.voltage_spin.value()
        step = self.step_spin.value()
        delay = self.delay_spin.value()
        threading.Thread(target=self._ramp_to_voltage, args=(target, step, delay), daemon=True).start()

    def _ramp_to_voltage(self, target, step, delay):
        # Simulate ramping
        current = 0  # Replace with self.instrument.getVoltage()
        direction = 1 if target > current else -1
        voltages = list(self._frange(current, target, step * direction))
        q = Coordinator().queue
        for v in voltages:
            # self.instrument.setVoltage(v)
            print(f"Keithley: Set voltage to {v}")
            q.put({'voltage': v})  # Notify other nodes
            time.sleep(delay)
        # self.instrument.setVoltage(target)
        q.put({'voltage': target})
        print(f"Keithley: Final voltage {target}")

    def _frange(self, start, stop, step):
        i = 0
        while (step > 0 and start + i * step <= stop) or (step < 0 and start + i * step >= stop):
            yield round(start + i * step, 6)
            i += 1
    def compute(self):
        self.get_output_flag()
        
class Lockin(NodeDataModel):
    name = 'Lockin'
    caption = 'Lock-in Model'
    caption_visible = True
    num_ports = {PortType.input: 1,
                 PortType.output: 1,
                 }
    data_type = {
        PortType.input: {
            0: Float64Data.data_type
        },
        PortType.output: {
            0: Float64Data.data_type
        }
    }

    def __init__(self, style=None, parent=None):
        super().__init__(style, parent)
        self._lockin_data = Float64Data(0.0)

    def out_data(self, port_index):
        return MyNodeData()

    def set_in_data(self, data: NodeData, port: Port):
        if port.index == 0:
            self._lockin_data = data

        if self._check_inputs():
            with self._compute_lock():
                self.compute()

    def compute(self):
        ...



from coordinator import Coordinator
import queue
class MeasurementNode(NodeDataModel):
    name = 'MeasurementNode'
    caption = 'Measurement Node'
    caption_visible = True
    num_ports = {PortType.input: 0, PortType.output: 0}
    data_type = {}

    def __init__(self, style=None, parent=None):
        super().__init__(style, parent)
        self._stop_event = threading.Event()
        self.paused = False
        threading.Thread(target=self.listen_for_ramp, daemon=True).start()

    def listen_for_ramp(self):
        q = Coordinator().queue
        while not self._stop_event.is_set():
            try:
                msg = q.get(timeout=0.5)
                voltage = msg.get('voltage')
                if self.paused:
                    print("MeasurementNode: Paused, ignoring voltage", voltage)
                    continue
                print(f"MeasurementNode: Received voltage {voltage}, taking measurement...")
                # Here, trigger your measurement logic
            except queue.Empty:
                continue

    def toggle_pause(self):
        self.paused = not self.paused
        if self.paused:
            self.pause_btn.setText("Resume")
        else:
            self.pause_btn.setText("Pause")

    def embedded_widget(self):
        widget = QWidget()
        layout = QVBoxLayout()
        layout.addWidget(QLabel("Measurement Node"))
        self.pause_btn = QPushButton("Pause")
        self.pause_btn.clicked.connect(self.toggle_pause)
        layout.addWidget(self.pause_btn)
        widget.setLayout(layout)
        return widget

    def close(self):
        self._stop_event.set()

import qtpynodeeditor as nodeeditor
import light
class NodeMan(QWidget):
    def __init__(self):
        super().__init__()
        style = light.lighttheme()
        layout = QVBoxLayout()
        layout.setContentsMargins(0, 0, 0, 0)
        registry = nodeeditor.DataModelRegistry()
    
        models = (FileModel, SourceModel)
        registry.register_model(Keithley2400, category='Sources',
                                    style=None)
        # registry.register_model(NaiveDataModel, category='Operations',
        #                             style=None)
        registry.register_model(MeasurementNode, category='Instruments',
                                    style=None)

        scene = nodeeditor.FlowScene(registry=registry)
        view = nodeeditor.FlowView(scene)
        view.show()
        layout.addWidget(view)

        node_extra  = scene.create_node(Keithley2400)
        # node_a = scene.create_node(NaiveDataModel)
        # node_b = scene.create_node(NaiveDataModel)

        # scene.create_connection(node_a[PortType.output][0],
        #                     node_b[PortType.input][0],
        #                     )

        # scene.create_connection(node_a[PortType.output][1],
        #                     node_b[PortType.input][1],
        #                     )

        self.setLayout(layout)
        self.setMinimumWidth(500)


if __name__ == '__main__':
    from PyQt6 import QtWidgets
    logging.basicConfig(level='DEBUG')
    app = QtWidgets.QApplication([])
    NodeMan()
    app.exec_()