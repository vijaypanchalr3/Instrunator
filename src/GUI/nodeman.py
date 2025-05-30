import contextlib
import logging
import threading

from qtpynodeeditor import (NodeData, NodeDataModel, NodeDataType,
                            NodeValidationState, Port, PortType)
from qtpynodeeditor.type_converter import TypeConverter
from PyQt6.QtWidgets import QComboBox, QVBoxLayout, QWidget

from numpy import float64 as npfloat64

from PyQt6.QtWidgets import QLabel
from PyQt6.QtGui import QColor, QPixmap, QPainter
from PyQt6.QtCore import QSize

class LEDIndicator(QLabel):
    def __init__(self, color="gray", size=12, parent=None):
        super().__init__(parent)
        self._size = size
        self.setFixedSize(QSize(size, size))
        self.set_color(color)

    def set_color(self, color: str):
        pixmap = QPixmap(self._size, self._size)
        pixmap.fill(QColor("transparent"))

        painter = QPainter(pixmap)
        painter.setBrush(QColor(color))
        painter.setPen(QColor("black"))
        painter.drawEllipse(0, 0, self._size - 1, self._size - 1)
        painter.end()

        self.setPixmap(pixmap)

class GetData():
    def __init__(self,Instrument):
        Instrument(GetData)

class npFloat64Data(NodeData):
    'Node data holding a npfloat64 value'
    data_type = NodeDataType("np.float64", "float64")

    def __init__(self, number: float = 0.0):
        self._number = number
        self._lock = threading.RLock()

    @property
    def lock(self):
        return self._lock

    @property
    def number(self) -> float:
        'The number data'
        return self._number

    def number_as_text(self) -> str:
        'Number as a string'
        return '%g' % self._number


class FlagData(NodeData):
    'Node data holding flag'
    data_type = NodeDataType("bool", "Bool")

    def __init__(self, number: int = 0):
        self._number = number
        self._lock = threading.RLock()

    @property
    def lock(self):
        return self._lock

    @property
    def number(self) -> int:
        'The number data'
        return self._number

    def number_as_text(self) -> str:
        'Number as a string'
        return str(self._number)

# class ArrayData(NodeData):
#     'Node data holding numpy array'
#     data_type = NodeDataModel("list","array","nparray")

#     def __init__(self, array):
#         self.array = array
#         self._lock = threading.RLock()

#     @property
#     def lock(self):
#         return self._lock
    
#     @property
#     def array(self) -> list:
#         'The array data'
#         return self._array
    




class MyNodeData(NodeData):
    data_type = NodeDataType(id='MyNodeData', name='My Node Data')


class SimpleNodeData(NodeData):
    data_type = NodeDataType(id='SimpleData', name='Simple Data')

from PyQt6.QtWidgets import QWidget, QComboBox, QHBoxLayout
class NaiveDataModel(NodeDataModel):
    name = 'NaiveDataModel'
    caption = 'Caption'
    caption_visible = True
    num_ports = {PortType.input: 2,
                 PortType.output: 2,
                 }
    data_type = {
        PortType.input: {
            0: MyNodeData.data_type,
            1: SimpleNodeData.data_type
        },
        PortType.output: {
            0: MyNodeData.data_type,
            1: SimpleNodeData.data_type
        },
    }
    def __init__(self, style=None, parent=None):
        super().__init__(style, parent)
        self._list = QComboBox()
        self._list.addItems(['Item 1', 'Item 2', 'Item 3'])
        self._list.setEditable(False)
        self._list.setCurrentIndex(0)
        self._list.setSizeAdjustPolicy(QComboBox.SizeAdjustPolicy.AdjustToContents)
        self._list.setMinimumWidth(100)
        self._list.setMinimumHeight(30)

    def out_data(self, port_index):
        if port_index == 0:
            return MyNodeData()
        elif port_index == 1:
            return SimpleNodeData()

    def set_in_data(self, node_data, port):
        ...
    def _load_keithley(self):
        pass
    def _on_source_changed(self, text):
        if text == "Keithley 2400":
            self._load_keithley()
            self.led.set_color("green")  # Device is ready
        else:
            self.led.set_color("gray")
            self._load_builtin_source(text)

        self.compute()
        self.data_updated.emit(0)
    def embedded_widget(self):
        self.combo = QComboBox()
        self.combo.addItems(["Constant", "Sine", "Keithley 2400"])
        self.combo.currentTextChanged.connect(self._on_source_changed)

        self.led = LEDIndicator("gray")

        container = QWidget()
        layout = QHBoxLayout()
        layout.setContentsMargins(0, 0, 0, 0)
        layout.addWidget(self.combo)
        layout.addWidget(self.led)
        container.setLayout(layout)

        return container
        



import qtpynodeeditor as nodeeditor

class NodeMan(QWidget):
    def __init__(self):
        super().__init__()
        layout = QVBoxLayout()
        layout.setContentsMargins(4, 4, 4, 4)
        registry = nodeeditor.DataModelRegistry()
    
        models = (NaiveDataModel)
        registry.register_model(NaiveDataModel, category='Operations',
                                    style=None)

        scene = nodeeditor.FlowScene(registry=registry)
        view = nodeeditor.FlowView(scene)
        view.show()
        layout.addWidget(view)


        node_a = scene.create_node(NaiveDataModel)
        node_b = scene.create_node(NaiveDataModel)

        scene.create_connection(node_a[PortType.output][0],
                            node_b[PortType.input][0],
                            )

        scene.create_connection(node_a[PortType.output][1],
                            node_b[PortType.input][1],
                            )

        self.setLayout(layout)
        self.setMinimumWidth(500)


if __name__ == '__main__':
    from PyQt6 import QtWidgets
    logging.basicConfig(level='DEBUG')
    app = QtWidgets.QApplication([])
    NodeMan()
    app.exec_()