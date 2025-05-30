classdef keithley6221 < handle
    properties (Access = private)
        device % visadev object
    end
    
    methods
        %% Constructor: Initialize Connection
        function obj = keithley6221(gpib_address)
            if nargin < 1
                gpib_address = 12; % Default GPIB address (modify if needed)
            end
            address = append("GPIB0::", num2str(gpib_address), "::INSTR");
            try
                obj.device = visadev(address);
                obj.device.InputBufferSize = 256;
                obj.device.Timeout = 10; % Timeout in seconds
                disp("Connected to Keithley 6221.");
                
                % Verify connection
                idn = obj.query('*IDN?');
                fprintf("Device ID: %s\n", idn);
                
            catch ME
                error("Failed to connect to Keithley 6221: %s", ME.message);
            end
        end

        %% Basic Communication
        function send(obj, command)
            writeline(obj.device, command);
        end

        function response = query(obj, command)
            writeline(obj.device, command);
            response = readline(obj.device);
        end

        function value = queryNum(obj, command)
            response = obj.query(command);
            value = str2double(response);
        end

        %% Output Control
        function enableOutput(obj)
            obj.send(':OUTP ON');
        end

        function disableOutput(obj)
            obj.send(':OUTP OFF');
        end

        function status = getOutputStatus(obj)
            status = obj.queryNum(':OUTP?');
        end

        %% Setting Current
        function setCurrent(obj, current)
            % Current in Amps (e.g., 1e-6 for 1µA)
            if abs(current) > 105e-3
                error("Current must be within ±105 mA.");
            end
            obj.send(sprintf(':SOUR:CURR %e', current));
        end

        function current = getCurrent(obj)
            current = obj.queryNum(':SOUR:CURR?');
        end

        %% Compliance Voltage
        function setComplianceVoltage(obj, voltage)
            % Voltage limit (0.1V - 105V)
            if voltage < 0.1 || voltage > 105
                error("Compliance voltage must be between 0.1V and 105V.");
            end
            obj.send(sprintf(':SOUR:CURR:COMP %f', voltage));
        end

        function voltage = getComplianceVoltage(obj)
            voltage = obj.queryNum(':SOUR:CURR:COMP?');
        end

        %% Measurement Functions
        function voltage = measureVoltage(obj)
            voltage = obj.queryNum(':MEAS:VOLT?');
        end

        function resistance = measureResistance(obj)
            resistance = obj.queryNum(':MEAS:RES?');
        end

        function current = measureCurrent(obj)
            current = obj.queryNum(':MEAS:CURR?');
        end

        %% Disconnect Function
        function disconnect(obj)
            if ~isempty(obj.device) && isvalid(obj.device)
                fclose(obj.device);
                delete(obj.device);
            end
            obj.device = [];
            fprintf('Keithley 6221 GPIB connection closed.\n');
        end
    end
end
