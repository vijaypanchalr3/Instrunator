import queue

class Coordinator:
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance.q = queue.Queue()
        return cls._instance

    @property
    def queue(self):
        return self.q