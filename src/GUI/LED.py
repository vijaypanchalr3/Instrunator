

from PyQt6.QtWidgets import QApplication, QWidget
from PyQt6.QtGui import QPainter, QPen, QColor, QRadialGradient, QBrush
from PyQt6.QtCore import QPointF
from PyQt6.QtCore import Qt, QSize


class LED(QWidget):
    width = 32
    height = 32
    color = {0: QColor(163, 17, 19),  # red
             1: QColor(72, 191, 25),  # Green
             2: QColor(199, 189, 9),  # Yellow
             3: QColor(4, 152, 158),  # Blue
             4: QColor(255, 0, 0)}  # extra
    
    def __init__(self, state: int = 1, parent: QWidget = None):
        super().__init__(parent)
        self._state = state
        self._color = self.color[state]
        self.setFixedSize(self.width, self.height)
   
    def setState(self, state):
        if state not in [0, 1, 2, 3, 4]:
            raise ValueError("State must be 0 (red), 1 (green), 2 (yellow), 3 (blue), or 4 just extra thing")
        self._color = self.color[state]
        self.update()

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing)
        rect = self.rect().adjusted(4, 4, -4, -4)
        pen = QPen(Qt.GlobalColor.black)
        pen.setWidth(2)
        painter.setPen(pen)
        grad = QRadialGradient(float(rect.center().x()), float(rect.center().y()), rect.width() / 2)
        grad.setColorAt(0, self._color.lighter(150))
        grad.setColorAt(0.7, self._color)
        grad.setColorAt(1, QColor(30, 30, 30))
        painter.setBrush(grad)
        painter.drawEllipse(rect)

        grad = QRadialGradient(float(rect.center().x())+3, float(rect.center().y())+3, rect.width()/1.8)
        grad.setColorAt(0, self._color.lighter(180))
        grad.setColorAt(0.7, self._color)
        grad.setColorAt(1, QColor(30, 30, 30))
        painter.setBrush(grad)
        painter.drawEllipse(rect)


if __name__ == "__main__":
    from PyQt6.QtWidgets import QWidget, QVBoxLayout
    import sys
    from PyQt6.QtWidgets import QPushButton
    app = QApplication(sys.argv)
    win = QWidget()
    layout = QVBoxLayout(win)
    led = LED(1)
    layout.addWidget(led)


    def cycle_led():
        current_state = getattr(led, "_state", 1)
        next_state = (current_state + 1) % 4
        led._state = next_state
        led.setState(next_state)

    btn = QPushButton("Cycle LED")
    btn.clicked.connect(cycle_led)
    layout.addWidget(btn)
    win.setWindowTitle("LED Indicator Demo")
    win.show()
    sys.exit(app.exec())        