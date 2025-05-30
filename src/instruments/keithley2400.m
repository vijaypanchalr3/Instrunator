classdef keithley2400 < handle
    properties (Access = private)
        device % visadev object
    end
    
    methods
        %% Constructor: Initialize Connection
        function obj = keithley2400(gpib_address)
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
            obj.send(':OUTP ON');
        end

        function disableOutput(obj)
            obj.send(':OUTP OFF');
        end
        
        function modeCurrent(obj)
            obj.send(':SENS:FUNC "CURR"');
        end

        function modeFixedVoltage(obj)
            obj.send(':SOUR:VOLT:MODE FIXED');
        end

        function modeVoltage(obj)
            obj.send(':SOUR:FUNC VOLT');
        end


        %% Output
        function out = readAll(obj)
            str = obj.query(':READ?');
            splitstr = strsplit(str, ',');
            out = str2double(splitstr);
        end

        function out = getVoltage(obj)
            out = obj.readAll();
            out = out(1);
        end

        function out = getLeakage(obj)
            out = obj.readAll();
            out = out(2);
        end

        function out = getCurrent(obj)
            out = obj.query(':MEAS:VOLT?');
            obj.send(':OUTP:ENAB:STAT ON');
        end

        % function disableOutput(obj)
        %     obj.send(':OUTP:ENAB:STAT OFF');
        % end

        function status = getOutputStatus(obj)
            status = obj.queryNum(':OUTP?');
        end

        %% get output
        function out = getOutput(obj)
            out = obj.queryNum(':READ?');
        end

        %% Voltage & Current Control
        function setVoltage(obj, voltage)
            obj.send(sprintf(':SOUR:VOLT %f', voltage));
        end

        function setCurrent(obj, current)
            obj.send(sprintf(':SOUR:CURR %f', current));
        end


        %% Compliance Limits
        function setVoltageCompliance(obj, voltageLimit)
            obj.send(sprintf('SENS:VOLT:PROT %f', voltageLimit));
        end

        function setCurrentCompliance(obj, currentLimit)
            obj.send(sprintf('SENS:CURR:PROT %f', currentLimit));
        end

        function out = getCurrentCompliance(obj)
            out = obj.query('SENS:CURR:PROT?');
        end
        
        function out = getVoltageCompliance(obj)
            out = obj.query('SENS:VOLT:PROT?');
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
