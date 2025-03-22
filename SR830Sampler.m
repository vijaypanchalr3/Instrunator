classdef SR830Sampler < handle
    properties
        lockin         % SR830 instance
        sampleRate     % Sampling rate in Hz
        duration       % Total duration in seconds
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
        function obj = SR830Sampler(lockin, sampleRate, duration)
            obj.lockin = lockin;
            obj.sampleRate = sampleRate;
            obj.duration = duration;
            obj.isRunning = false;

            % Initialize data storage
            obj.data.time = [];
            obj.data.X = [];
            obj.data.Y = [];
            obj.data.R = [];
            obj.data.Theta = [];

            % Setup plotting
            obj.initPlot();
        end
        
        %% Start Sampling & Plotting
        function start(obj)
            obj.isRunning = true;
            fprintf("Starting sampling for %.2f seconds...\n", obj.duration);
            
            startTime = tic;  % Start timing
            while obj.isRunning && toc(startTime) < obj.duration
                % Record timestamp
                elapsedTime = toc(startTime);
                obj.data.time(end + 1) = elapsedTime;
                
                % Read data from SR830
                [X, Y, R, Theta] = obj.lockin.readMeasurements();
                obj.data.X(end + 1) = X;
                obj.data.Y(end + 1) = Y;
                obj.data.R(end + 1) = R;
                obj.data.Theta(end + 1) = Theta;

                % Update plot
                obj.updatePlot(elapsedTime, X, Y, R, Theta);
                
                % Wait for next sample
                pause(1 / obj.sampleRate);
            end
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
            obj.lines.X = animatedline(obj.ax, 'Color', 'r', 'LineWidth', 1.5, 'DisplayName', 'X');
            obj.lines.Y = animatedline(obj.ax, 'Color', 'b', 'LineWidth', 1.5, 'DisplayName', 'Y');
            obj.lines.R = animatedline(obj.ax, 'Color', 'g', 'LineWidth', 1.5, 'DisplayName', 'R');
            obj.lines.Theta = animatedline(obj.ax, 'Color', 'm', 'LineWidth', 1.5, 'DisplayName', 'Theta');
            
            xlabel(obj.ax, 'Time (s)');
            ylabel(obj.ax, 'Signal (V or deg)');
            title(obj.ax, 'SR830 Real-Time Measurement');
            legend(obj.ax, 'show');
            grid(obj.ax, 'on');
        end

        %% Update Live Plot
        function updatePlot(obj, t, X, Y, R, Theta)
            addpoints(obj.lines.X, t, X);
            addpoints(obj.lines.Y, t, Y);
            addpoints(obj.lines.R, t, R);
            addpoints(obj.lines.Theta, t, Theta);
            
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
