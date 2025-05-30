classdef Keithley < handle
    properties
        visaObj    % VISA object for communication
        maxVoltage % Max allowed voltage (safety)
        maxCurrent % Max allowed current (safety)
    end
    
    methods
        % Constructor: Connect to instrument
        function obj = Keithley(address, maxVoltage, maxCurrent)
            obj.visaObj = visadev(address);
            obj.maxVoltage = maxVoltage;
            obj.maxCurrent = maxCurrent;
            writeline(obj.visaObj, '*RST'); % Reset device
            writeline(obj.visaObj, ':SYST:BEEP:STAT OFF'); % Disable beeping
        end

        % Set source mode: 'VOLT' for voltage, 'CURR' for current
        function setMode(obj, mode)
            validModes = ["VOLT", "CURR"];
            if any(strcmp(mode, validModes))
                writeline(obj.visaObj, sprintf(':SOUR:FUNC %s', mode));
            else
                error('Invalid mode. Use "VOLT" for voltage source or "CURR" for current source.');
            end
        end

        % Set voltage source (with safety check)
        function setVoltage(obj, voltage)
            if abs(voltage) > obj.maxVoltage
                error('Voltage exceeds safety limit of %g V', obj.maxVoltage);
            end
            writeline(obj.visaObj, sprintf(':SOUR:VOLT %f', voltage));
        end

        % Set current source (with safety check)
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

        % Ramping function (start -> over -> start) with plotting
        function rampAndMeasure(obj, startValue, overValue, stepSize, holdTime, mode)
            % Validate mode
            if ~any(strcmp(mode, ["VOLT", "CURR"]))
                error('Invalid mode. Use "VOLT" or "CURR".');
            end

            % Setup figure
            figure;
            hold on;
            xlabel('Step');
            ylabel('Measured Value');
            title('Keithley Ramp Measurement');
            grid on;

            obj.setMode(mode);
            obj.enableOutput();

            stepNum = 0;
            while true  % Infinite loop until stopped manually
                % Forward ramp
                for value = startValue:stepSize:overValue
                    obj.applyAndMeasure(value, mode, stepNum);
                    stepNum = stepNum + 1;
                    pause(holdTime);
                end

                % Reverse ramp
                for value = overValue:-stepSize:startValue
                    obj.applyAndMeasure(value, mode, stepNum);
                    stepNum = stepNum + 1;
                    pause(holdTime);
                end
            end
        end

        % Apply value and measure response
        function applyAndMeasure(obj, value, mode, stepNum)
            if mode == "VOLT"
                obj.setVoltage(value);
                measured = obj.measureCurrent();
            else
                obj.setCurrent(value);
                measured = obj.measureVoltage();
            end

            fprintf('Step %d | %s = %.3f | Measured = %.3f\n', stepNum, mode, value, measured);

            % Update plot
            plot(stepNum, measured, 'ro');
            drawnow;
        end

        % Destructor: Clean up VISA object
        function delete(obj)
            obj.disableOutput();
            clear obj.visaObj;
        end
    end
end
