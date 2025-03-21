classdef SR830Sampler < handle
    properties
        lockin         % SR830 instance
        settleTime
        data           % Data storage (struct)
        isRunning      % Control flag for stopping
    end
    
    properties (Access = private)
        fig            % Figure for plotting
        ax             % Axes for plotting
        lines          % Animated lines
    end
    
    methods
        %% Constructor: Initialize Sampler
        function obj = SR830Sampler(lockin, settleTime)
            obj.lockin = lockin;
            obj.settleTime = settleTime;
            obj.isRunning = false;

            % Initialize data storage
            obj.data.Aux1Voltage = [];
            obj.data.InputVoltage = [];

            % Setup plotting
            obj.initPlot();
        end
        
        %% Start Sampling & Plotting
        function data = Aux1R(obj, startVoltage, rampRate, endVoltage)
            obj.isRunning = true;

            for voltage = startVoltage:rampRate:endVoltage
                obj.lockin.setAux1(voltage);
                % Wait for system to stabilize
                pause(obj.settleTime);
                % Read input voltage (magnitude of signal, "R" value)
                R = obj.lockin.getR();
                pause(obj.settleTime);
                % Store data
                obj.data.Aux1Voltage(end+1) = voltage;
      
                obj.data.InputVoltage(end+1) = R;
                % obj.updatePlot(voltage, R);
                fprintf('Aux1 Voltage: %.4f V | Measured Voltage: %.10f V\n', voltage, R);
            end
            data = obj.data;
            fprintf("Sampling complete.\n");
        end
        
        %% Stop Sampling
        function stop(obj)
            obj.isRunning = false;
            fprintf("Sampling stopped.\n");
        end
        
        %% Initialize Live Plot
        function initPlot(obj)
            obj.fig = figure('Name', 'SR830 Data Logger', 'NumberTitle', 'off');
            obj.ax = axes(obj.fig);
            hold(obj.ax, 'on');
            
            % Create animated lines for real-time plotting
            obj.lines.voltage = animatedline(obj.ax, 'Color', 'r', 'LineWidth', 1.5, 'DisplayName', 'X');
            obj.lines.R = animatedline(obj.ax, 'Color', 'g', 'LineWidth', 1.5, 'DisplayName', 'R');
                       
            xlabel(obj.ax, 'Aux (V)');
            ylabel(obj.ax, 'R (V)');
            title(obj.ax, 'SR830');
            legend(obj.ax, 'show');
            grid(obj.ax, 'on');
        end

        %% Update Live Plot
        function updatePlot(obj, voltage, R)
            addpoints(obj.lines.voltage, voltage);
            addpoints(obj.lines.R,R);
            drawnow;
        end
        
        %% Destructor: Cleanup
        function delete(obj)
            obj.stop();
            if isvalid(obj.fig)
                close(obj.fig);
            end
        end
    end
end
