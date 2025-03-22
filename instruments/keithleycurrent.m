classdef keithleycurrent < handle
    properties
        visaObj    % VISA object for communication
        maxVoltage % Max allowed voltage (safety)
        maxCurrent % Max allowed current (safety)
    end
    
    methods
        % Constructor: Connect to instrument
        function obj = keithleycurrent(gpib_address, maxVoltage, maxCurrent)
            if nargin < 1
                gpib_address = 24;
            end
            address = append("GPIB0::",num2str(gpib_address),"::INSTR");
            try
                obj.visaObj = visadev(address);
            catch ME
                error("Failed to connect to Keitley current source: %s", ME.message);
            end
            obj.maxVoltage = maxVoltage;
            obj.maxCurrent = maxCurrent;
            writeline(obj.visaObj, '*RST'); % Reset device
            writeline(obj.visaObj, ':SYST:BEEP:STAT OFF'); % Disable beeping
        end

        % Set output mode: 0 = Voltage source, 1 = Current source
        function setMode(obj, mode)
            if mode == 0
                writeline(obj.visaObj, ':SOUR:FUNC VOLT'); % Set to voltage source mode
            elseif mode == 1
                writeline(obj.visaObj, ':SOUR:FUNC CURR'); % Set to current source mode
            else
                error('Invalid mode. Use 0 for voltage source, 1 for current source.');
            end
        end
        
        % Set output voltage (checks safety limit)
        function setVoltage(obj, voltage)
            if abs(voltage) > obj.maxVoltage
                error('Voltage exceeds safety limit of %g V', obj.maxVoltage);
            end
            writeline(obj.visaObj, sprintf(':SOUR:VOLT %f', voltage));
        end
        
        % Set output current (checks safety limit)
        function setCurrent(obj, current)
            if abs(current) > obj.maxCurrent
                error('Current exceeds safety limit of %g A', obj.maxCurrent);
            end
            writeline(obj.visaObj, sprintf(':SOUR:CURR %f', current));
        end

        % Measure voltage
        function voltage = measureVoltage(obj)
            writeline(obj.visaObj, ':MEAS:VOLT?');
            voltage = str2double(readline(obj.visaObj));
        end

        % Measure current
        function current = measureCurrent(obj)
            writeline(obj.visaObj, ':MEAS:CURR?');
            current = str2double(readline(obj.visaObj));
        end

        % Enable output
        function enableOutput(obj)
            writeline(obj.visaObj, ':OUTP ON');
        end

        % Disable output
        function disableOutput(obj)
            writeline(obj.visaObj, ':OUTP OFF');
        end

        % Destructor: Clean up VISA object
        function delete(obj)
            obj.disableOutput();
            clear obj.visaObj;
        end
    end
end
