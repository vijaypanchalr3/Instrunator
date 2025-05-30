class sr830wrapper:
    """
    A wrapper class for the SR830 lock-in amplifier.
    This class provides methods to interact with the SR830 device.
    param for wrapper:
    eng: matlab engine instance
    device: SR830 device instance
    """
    SENSITIVITY_VALUES = range(0,27)
    TIME_CONSTANT_VALUES = range(0,20)
    FILTER_SLOPE_VALUES = [6, 12, 18, 24]

    def __init__(self, eng, gpib_address):
        self.device = eng.sr830(gpib_address)
        self.eng = eng

    def send(self, command)->None:
        self.eng.send(self.device,command)

    def query(self, command):
        return self.eng.query(self.device, command)
    
    def querynum(self, command):
        return self.eng.queryNum(self.device, command)

    def set_parameter(self, parameter, value):
        """
        Set a parameter on the SR830 device.

        :param parameter: The parameter to set.
        :param value: The value to set the parameter to.
        """
        self.device.set_parameter(parameter, value)