% Tasks from vijay
% TASK: need debugging once. 
% TASK: control everything with VISADEV module !getting issues with it need
% drivers again
% TASK: class must contain trial for connection and we put only address
% baudrate and stuff

classdef SR830
    properties
        visaObj  % VISA object for communication
    end
    
    methods
        % Constructor
        function obj = SR830(visaAddress)
            % Create a VISA object with the given address
            if nargin > 0
                obj.visaObj = visa('AGILENT', visaAddress);
                fopen(obj.visaObj);
                disp(['Connected to SR830 at ', visaAddress]);
            else
                error('Visa address must be provided.');
            end
        end
        
        function close(obj)
            fclose(obj.visaObj);
            delete(obj.visaObj);
            clear obj;
            disp('Connection closed and object deleted.');
        end
        
        % Query the device ID
        function idn = queryID(obj)
            fprintf(obj.visaObj, '*IDN?');
            idn = fscanf(obj.visaObj);
            disp(['Device ID: ', idn]);
        end
        
        % Set reference frequency (in Hz)
        function setRefFrequency(obj, freq)
            if freq >= 0.1 && freq <= 102000  % SR830 freq range: 0.1 Hz to 102 kHz
                fprintf(obj.visaObj, ['FREQ ', num2str(freq)]);
                disp(['Reference frequency set to ', num2str(freq), ' Hz']);
            else
                warning('Reference frequency must be between 0.1 Hz and 102 kHz.');
            end
        end
        
        % Get reference frequency (in Hz)
        function freq = getRefFrequency(obj)
            fprintf(obj.visaObj, 'FREQ?');
            freq = fscanf(obj.visaObj);
            disp(['Reference frequency: ', freq, ' Hz']);
        end
        
        % Set input signal amplitude
        function setAmplitude(obj, amplitude)
            if amplitude >= 0 && amplitude <= 10  % SR830 input signal range: 0-10 V
                fprintf(obj.visaObj, ['AMPT ', num2str(amplitude)]);
                disp(['Signal amplitude set to ', num2str(amplitude), ' V']);
            else
                warning('Amplitude must be between 0 and 10 V.');
            end
        end
        
        % Get input signal amplitude
        function amplitude = getAmplitude(obj)
            fprintf(obj.visaObj, 'AMPT?');
            amplitude = fscanf(obj.visaObj);
            disp(['Signal amplitude: ', amplitude, ' V']);
        end
        
        % Get the X output (real part)
        function X = getX(obj)
            fprintf(obj.visaObj, 'OUTX?');
            X = fscanf(obj.visaObj);
            disp(['X output: ', X]);
        end
        
        % Get the Y output (imaginary part)
        function Y = getY(obj)
            fprintf(obj.visaObj, 'OUTY?');
            Y = fscanf(obj.visaObj);
            disp(['Y output: ', Y]);
        end
        
        % Get the magnitude (R) output
        function R = getMagnitude(obj)
            fprintf(obj.visaObj, 'OUTR?');
            R = fscanf(obj.visaObj);
            disp(['Magnitude (R): ', R]);
        end
        
        % Get the phase (Theta) output
        function Theta = getPhase(obj)
            fprintf(obj.visaObj, 'OUTP?');
            Theta = fscanf(obj.visaObj);
            disp(['Phase (Theta): ', Theta]);
        end
        
        % Get the time constant
        function tau = getTimeConstant(obj)
            fprintf(obj.visaObj, 'TC?');
            tau = fscanf(obj.visaObj);
            disp(['Time constant: ', tau, ' s']);
        end
        
        % Set time constant (in seconds)
        function setTimeConstant(obj, timeConst)
            validTimeConsts = [1e-6, 3e-6, 1e-5, 3e-5, 1e-4, 3e-4, 1e-3, 3e-3, 1e-2, 3e-2, 0.1, 0.3, 1, 3, 10, 30];
            if ismember(timeConst, validTimeConsts)
                fprintf(obj.visaObj, ['TC ', num2str(timeConst)]);
                disp(['Time constant set to ', num2str(timeConst), ' s']);
            else
                warning('Invalid time constant. Choose from valid values.');
            end
        end
        
    end
end
