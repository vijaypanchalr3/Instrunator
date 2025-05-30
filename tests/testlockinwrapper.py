class testlockinwrapper:
    def __init__(self, eng, gpib_address):
        
        self.device = eng.sr830(gpib_address)
        self.eng = eng
        self.SENSITIVITY_VALUES = range(0, 27)
        self.TIME_CONSTANT_VALUES = range(0, 20)
        self.FILTER_SLOPE_VALUES = [6, 12, 18, 24]

    def send(self, command) -> None:
        # self.eng.writeline(self.device, command)
        pass
    
    def query(self, command):
        # self.send(command)
        # return self.eng.readline(self.device, command)
        pass
    
    def querynum(self, command):
        # return self.eng.queryNum(self.device, command)
        pass
    
    
    def get_all_measurements(self): 
        X = self.eng.rand()
        Y = self.eng.rand()
        R = self.eng.rand()
        Theta = self.eng.rand()
        return [X,Y,R,Theta]
    
    
    def setFrequency(self, freq):
        pass

    def setPhase(self, phase):
        pass

    def setAmplitude(self, amplitude):
        pass

    def setSensitivity(self, level):
        pass

    def setTimeConstant(self, timeConst):
        pass

    def setLowPassFilter(self, slope):
        pass

    def setSyncFilter(self, enabled):
        pass

    def setReserveMode(self, mode):
        pass

    def setOutputDisplay(self, ch1, ch2):
        pass

    def getX(self):
        X = self.eng.rand()
        return X
    def getY(self):
        Y = self.eng.rand()
        return Y
    def getR(self):
        R = self.eng.rand()
        return R
    def getP(self):
        P = self.eng.rand()
        return P
    def getXY(self, settleTime):
        self.eng.pause(settleTime)
        X = self.eng.rand()
        Y = self.eng.rand()
        OutputXY = [X, Y]
        return OutputXY
    def getVoltage(self):
        voltage = self.eng.rand()
        return voltage