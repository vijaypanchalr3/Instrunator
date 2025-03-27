classdef Keithley2400 < handle
    properties (Access = private)
        device % visadev object
    end
    
    methods
        %% Constructor: Initialize Connection
        function obj = Keithley2400(gpib_address)
            if nargin < 1
                gpib_address = 24; % Default GPIB address
            end
            address = sprintf("GPIB0::%d::INSTR", gpib_address);
            try
                obj.device = visadev(address);
                obj.device.InputBufferSize = 256;
                obj.device.Timeout = 10; % Timeout in seconds
                disp("Connected to Keithley 2400.");
                
                % Verify connection
                idn = obj.query('*IDN?');
                fprintf("Device ID: %s\n", idn);
            catch ME
                error("Failed to connect to Keithley 2400: %s", ME.message);
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
            obj.send('OUTP ON');
        end

        function disableOutput(obj)
            obj.send('OUTP OFF');
        end

        %% Voltage & Current Control
        function setVoltage(obj, voltage)
            obj.send(sprintf('SOUR:VOLT %f', voltage));
        end

        function setCurrent(obj, current)
            obj.send(sprintf('SOUR:CURR %f', current));
        end

        function voltage = getVoltage(obj)
            voltage = obj.queryNum('MEAS:VOLT?');
        end

        function current = getCurrent(obj)
            current = obj.queryNum('MEAS:CURR?');
        end

        %% Compliance Limits
        function setVoltageCompliance(obj, voltageLimit)
            obj.send(sprintf('SENS:VOLT:PROT %f', voltageLimit));
        end

        function setCurrentCompliance(obj, currentLimit)
            obj.send(sprintf('SENS:CURR:PROT %f', currentLimit));
        end

        %% Disconnect Handling
        function disconnect(obj)
            if ~isempty(obj.device) && isvalid(obj.device)
                fclose(obj.device);
                delete(obj.device);
            end
            obj.device = [];
            fprintf('GPIB connection to Keithley 2400 closed.\n');
        end
    end
end
