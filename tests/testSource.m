classdef testSource < handle
    properties (Access = private)
        device % visadev object
    end
    
    methods
        %% Constructor: Initialize Connection
        function obj = testSource(gpib_address)
            if nargin < 1
                gpib_address = 24; % Default GPIB address
            end
            address = sprintf("GPIB0::%d::INSTR", gpib_address);
  
            % obj.device = visadev(address);
            fprintf(address);
            obj.device = NaN;
            
            disp("Dummy Source is initialised");
            
        end

      
        function out = getVoltage(obj)
            out = rand();
        end

        function out = getCurrent(obj)
            out = rand();
        end

        function status = getOutputStatus(obj)
            status = 1;
        end

        function out = getOutput(obj)
            out = [rand(), rand(),rand(), rand()];
        end

        function setVoltage(obj, voltage)
            % pass
        end

        function setCurrent(obj, current)
            % pass
        end


        %% Disconnect Handling
        function disconnect(obj)
            obj.device = [];
            fprintf('Dummy Source is disconnected.\n');
        end
    end
end
