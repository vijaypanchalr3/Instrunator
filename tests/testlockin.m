classdef testlockin < handle
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
        function obj = testlockin(gpib_address)
            if nargin < 1
                gpib_address = 8; % Default GPIB address
            end
            address = append("GPIB0::",num2str(gpib_address),"::INSTR");
  
            % obj.device = visadev(address);
            fprintf(address);
            obj.device = NaN;
            
            disp("Dummy lockin is initialised");
        end

        function setFrequency(obj, freq)
            % pass
        end

        function setPhase(obj, phase)
           % pass
        end

        function setAmplitude(obj, amplitude)
            % pass
        end

        function setSensitivity(obj, level)
            % pass
        end

        function setTimeConstant(obj, timeConst)
            % pass
        end

        function setLowPassFilter(obj, slope)
            % pass
        end

        function setSyncFilter(obj, enabled)
            % pass
        end

        function setReserveMode(obj, mode)
            % pass
        end

        %% Output and Display Settings
        function setOutputDisplay(obj, ch1, ch2)
            % pass
        end

        function X = getX(obj)
            X = rand();
        end

        function Y = getY(obj)
            Y = rand();
        end

        function R = getR(obj)
            R = rand();
            % outR = str2double(R);
        end

        function P = getP(obj)
            P = rand();
        end
        
        function [X, Y, R, Theta] = readMeasurements(obj)
            X = rand();
            Y = rand();
            R = rand();
            Theta = rand();
        end

        %% Reference Settings
        function setReferenceTrigger(obj, mode)
            % pass
        end
        function setVoltage(obj, voltage)
            % pass
        end
        function setAux2(obj, voltage)
            % pass
        end
        function setAux3(obj, voltage)
            % pass
        end
        function setAux4(obj, voltage)
            % pass
        end
        function disconnect(obj)
            
            obj.device = [];
            fprintf('Dummy lockin is disconnected.\n');
        end
    end
end
