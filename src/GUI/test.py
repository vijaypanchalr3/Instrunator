from PyQt6.QtWidgets import QWidget, QApplication, QVBoxLayout
from PyQt6.QtGui import QPainter, QPen, QColor, QRadialGradient
from PyQt6.QtCore import Qt, QSize, QPointF
import sys

class LED(QWidget):
    def __init__(self, color=QColor(0, 255, 0), parent=None):
        super().__init__(parent)
        if isinstance(color, str):
            color = QColor(color)
        self._color = color
        self.setFixedSize(32, 32)

    def set_color(self, color):
        if isinstance(color, str):
            color = QColor(color)
        self._color = color
        self.update()

    def sizeHint(self):
        return QSize(32, 32)

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

if __name__ == "__main__":
    app = QApplication(sys.argv)
    win = QWidget()
    layout = QVBoxLayout(win)
    led = LED("red")
    layout.addWidget(led)
    win.setWindowTitle("LED Indicator Demo")
    win.show()
    sys.exit(app.exec())