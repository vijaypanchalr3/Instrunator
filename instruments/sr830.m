classdef sr830 < handle
    properties (Access = private)
        device % visadev object
    end
    
    properties (Constant)
        % Allowed values for sensitivity, time constant, etc.
        SENSITIVITY_VALUES = 0:26;  % Valid sensitivity levels (0-26)
        TIME_CONSTANT_VALUES = 0:19; % Valid time constants (0-19)
        FILTER_SLOPE_VALUES = [6, 12, 18, 24]; % dB/oct
    end
    
    methods
        %% Constructor: Initialize Connection
        function obj = sr830(gpib_address)
            if nargin < 1
                gpib_address = 8; % Default GPIB address
            end
            address = append("GPIB0::",num2str(gpib_address),"::INSTR");
            try
                obj.device = visadev(address);
                obj.device.Timeout = 10; % Timeout in seconds
                disp("Connected to SR830.");
                
                % Verify connection
                idn = obj.query('*IDN?');
                fprintf("Device ID: %s\n", idn);
                
            catch ME
                error("Failed to connect to SR830: %s", ME.message);
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

        %% System and Status Commands
        function reset(obj)
            obj.send('*RST'); % Reset device
        end

        function clearStatus(obj)
            obj.send('*CLS'); % Clear status registers
        end

        function status = readStatus(obj)
            status = obj.queryNum('*STB?'); % Read status byte
        end

        function lockinID = getID(obj)
            lockinID = obj.query('*IDN?'); % Get device ID
        end

        %% Measurement Settings
        function setReferenceSource(obj, source)
            % source: 0 = Internal, 1 = External
            if ~ismember(source, [0, 1])
                error("Invalid reference source. Use 0 (Internal) or 1 (External).");
            end
            obj.send(sprintf('FMOD %d', source));
        end

        function setFrequency(obj, freq)
            if freq < 0.001 || freq > 102000
                error("Frequency must be in range 0.001 Hz to 102 kHz.");
            end
            obj.send(sprintf("FREQ %f", freq));
        end

        function setPhase(obj, phase)
            if phase < -360 || phase > 360
                error("Phase must be in range -360° to 360°.");
            end
            obj.send(sprintf("PHAS %f", phase));
        end

        function setAmplitude(obj, amplitude)
            if amplitude < 0.004 || amplitude > 5
                error("Amplitude must be in range 0.004 V to 5 V.");
            end
            obj.send(sprintf("SLVL %f", amplitude));
        end

        function setSensitivity(obj, level)
            if ~ismember(level, obj.SENSITIVITY_VALUES)
                error("Invalid sensitivity level. Use values 0-26.");
            end
            obj.send(sprintf("SENS %d", level));
        end

        function setTimeConstant(obj, timeConst)
            if ~ismember(timeConst, obj.TIME_CONSTANT_VALUES)
                error("Invalid time constant. Use values 0-19.");
            end
            obj.send(sprintf("OFLT %d", timeConst));
        end

        function setLowPassFilter(obj, slope)
            if ~ismember(slope, obj.FILTER_SLOPE_VALUES)
                error("Invalid low-pass filter slope. Use values: 6, 12, 18, 24 dB/oct.");
            end
            obj.send(sprintf("OFSL %d", find(obj.FILTER_SLOPE_VALUES == slope) - 1));
        end

        function setSyncFilter(obj, enabled)
            if ~ismember(enabled, [0, 1])
                error("Invalid sync filter setting. Use 0 (Off) or 1 (On).");
            end
            obj.send(sprintf("SYNC %d", enabled));
        end

        function setReserveMode(obj, mode)
            if ~ismember(mode, [0, 1, 2])
                error("Invalid reserve mode. Use 0 (High Reserve), 1 (Normal), 2 (Low Noise).");
            end
            obj.send(sprintf("RMOD %d", mode));
        end

        %% Output and Display Settings
        function setOutputDisplay(obj, ch1, ch2)
            % ch1, ch2: 0=X, 1=Y, 2=R, 3=θ
            if ~ismember(ch1, 0:3) || ~ismember(ch2, 0:3)
                error("Invalid display channel. Use 0 (X), 1 (Y), 2 (R), 3 (θ).");
            end
            obj.send(sprintf("DDEF 1, %d, 0", ch1));
            obj.send(sprintf("DDEF 2, %d, 0", ch2));
        end

        function X = getX(obj)
            X = obj.queryNum('OUTP? 1');
        end

        function Y = getY(obj)
            Y = obj.queryNum('OUTP? 2');
        end

        function R = getR(obj)
            R = obj.queryNum('OUTP? 3');
        end

        function P = getP(obj)
            P = obj.queryNum('OUTP? 4');
        end

        function [X, Y, R, Theta] = readMeasurements(obj)
            X = obj.queryNum('OUTP? 1');
            Y = obj.queryNum('OUTP? 2');
            R = obj.queryNum('OUTP? 3');
            Theta = obj.queryNum('OUTP? 4');
        end

        %% Reference Settings
        function setReferenceTrigger(obj, mode)
            if ~ismember(mode, [0, 1, 2])
                error("Invalid reference trigger mode. Use 0 (Sine Zero Crossing), 1 (TTL Rising), 2 (TTL Falling).");
            end
            obj.send(sprintf("RSLP %d", mode));
        end
    end
end
