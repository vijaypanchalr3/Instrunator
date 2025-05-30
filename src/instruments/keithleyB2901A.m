classdef keithleyB2901A < handle
    properties (Access = private)
        device % visadev object
    end
    
    methods
        %% Constructor: Initialize Connection
        function obj = keithleyB2901A(gpib_address)
            if nargin < 1
                gpib_address = 5; % Default GPIB address (modify if needed)
            end
            address = append("GPIB0::", num2str(gpib_address), "::INSTR");
            try
                obj.device = visadev(address);
                obj.device.InputBufferSize = 256;
                obj.device.Timeout = 10; % Timeout in seconds
                disp("Connected to Keithley B2901A.");
                
                % Verify connection
                idn = obj.query('*IDN?');
                fprintf("Device ID: %s\n", idn);
                
            catch ME
                error("Failed to connect to Keithley B2901A: %s", ME.message);
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

        %% Setting Voltage & Current
        function setVoltage(obj, voltage)
            % Voltage range depends on model (adjust as needed)
            obj.send(sprintf(':SOUR:VOLT %e', voltage));
        end

        function voltage = getVoltage(obj)
            voltage = obj.queryNum(':SOUR:VOLT?');
        end

        function setCurrent(obj, current)
            % Current range depends on model (adjust as needed)
            obj.send(sprintf(':SOUR:CURR %e', current));
        end

        function current = getCurrent(obj)
            current = obj.queryNum(':SOUR:CURR?');
        end

        %% Compliance Limits
        function setVoltageCompliance(obj, voltage)
            obj.send(sprintf(':SENS:VOLT:PROT %f', voltage));
        end

        function voltage = getVoltageCompliance(obj)
            voltage = obj.queryNum(':SENS:VOLT:PROT?');
        end

        function setCurrentCompliance(obj, current)
            obj.send(sprintf(':SENS:CURR:PROT %e', current));
        end

        function current = getCurrentCompliance(obj)
            current = obj.queryNum(':SENS:CURR:PROT?');
        end

        %% Measurement Functions
        function voltage = measureVoltage(obj)
            voltage = obj.queryNum(':MEAS:VOLT?');
        end

        function current = measureCurrent(obj)
            current = obj.queryNum(':MEAS:CURR?');
        end

        function resistance = measureResistance(obj)
            resistance = obj.queryNum(':MEAS:RES?');
        end

        %% Disconnect Function
        function disconnect(obj)
            if ~isempty(obj.device) && isvalid(obj.device)
                fclose(obj.device);
                delete(obj.device);
            end
            obj.device = [];
            fprintf('Keithley B2901A GPIB connection closed.\n');
        end
    end
end
