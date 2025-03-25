classdef toySR830Sampler < handle
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
        Z
        contourPlot
    end
    
    methods
        %% Constructor: Initialize Sampler
        function obj = toySR830Sampler(lockin, settleTime)
            obj.lockin = lockin;
            obj.settleTime = settleTime;
            obj.isRunning = false;

            % Initialize data storage
            obj.data.Aux1 = [];
            obj.data.Aux2 = [];
            obj.data.X = [];
            obj.data.Y = [];

            % Setup plotting
            % obj.initPlot();
        end
        
        %% Start Sampling & Plotting
        % function data = Aux1R(obj, startVoltage, rampRate, endVoltage)
        %     obj.isRunning = true;
        %     for voltage = startVoltage:rampRate:endVoltage
        %         % obj.lockin.Aux1(voltage);
        %         % Wait for system to stabilize
        %         pause(obj.settleTime);
        %         % Read input voltage (magnitude of signal, "R" value)
        %         % R = obj.lockin.getR();
        %         R = rand();
        %         pause(obj.settleTime);
        %         % Store data
        %         obj.data.Aux1Voltage(end+1) = voltage;
        % 
        %         obj.data.InputVoltage(end+1) = R;
        %         obj.updatePlot(voltage, R);
        %         fprintf('Aux1 Voltage: %.4f V | Measured Voltage: %.10f V\n', voltage, R);
        %     end
        %     data = obj.data;
        %     fprintf("Sampling complete.\n");
        % end

        function data = voltage_sweep(obj, Voltage1, Voltage2)
            obj.isRunning = true;
            if nargin < 2
                obj.initPlot();
                for v1 = Voltage1(1):Voltage1(3):Voltage1(2)
                    % obj.lockin.setAux1(v1);

                    pause(obj.settleTime);
                    
                    X = rand();
                    Y = rand();

                    obj.data.Aux1(end+1) = voltage;
                    obj.data.X(end+1) = X;
                    obj.data.Y(end+1) = Y;
                    % obj.updatePlot_1d(voltage, X, Y);
                    fprintf('Aux1: %.4f V | X: %.10f V\n | Y: %.10f V\n', voltage, X, Y);
                end
                data = obj.data;
                fprintf("Sampling complete.\n");
            else
                meshV1 = linspace(Voltage1(1), Voltage1(2), Voltage1(3));
                meshV2 = linspace(Voltage2(1), Voltage2(2), Voltage2(3));
                [mV1, mV2] = meshgrid(meshV1, meshV2);

                obj.init2Dplot(mV1, mV2)
                %CONFUSED HERE: HOW TO GET OVER WITH THIS MESHING AND DIRECTLY USING IT THERE.
                i = 1;
                j = 1;
                for v1 = Voltage1(1):Voltage1(3):Voltage1(2)
                    % obj.lockin.setAux1(v1);
                    for v2 = Voltage2(1):Voltage2(3):Voltage2(2)
                        % obj.lockin.setAux2(v2);
                        
                        pause(obj.settleTime);
                        
                        X = rand();
                        Y = rand();

                        obj.data.Aux2(end+1) = v2;
                        obj.data.X(end+1) = X;
                        obj.data.Y(end+1) = Y;
                        
                        obj.Z(i,j) = sqrt(X^2+Y^2);
                        j = j+1;
                        % fprintf('Aux1: %.4f V | Aux2: %.4f V | X: %.10f V\n | Y: %.10f V\n', v1, v2, X, Y);
                    end
                    disp(obj.Z);
     
                    obj.data.Aux1(end+1) = v1;
                    i=i+1;

                    % This is for plotting don't bother
                    if sum(~isnan(obj.Z(:))) >= 4 && i>1
                        % If an existing contour plot exists and is valid, delete it
                        if ~isempty(obj.contourPlot)
                            if all(isgraphics(obj.contourPlot(:)))
                                delete(obj.contourPlot);
                            end
                        end
        
        
                        obj.contourPlot = contourf(mV1, mV2, obj.Z, 20, 'LineColor', 'none');
                     
                    end

                    
                end
                data = obj.data;
                fprintf("Sampling complete.\n");
            end  
        end
        
        %% Stop Sampling
        function stop(obj)
            obj.isRunning = false;
            fprintf("Sampling stopped.\n");
        end
        
        %% Initialize Live Plot
        function init2Dplot(obj, axis1, axis2)
            obj.fig = figure('Name', 'SR830 Data Logger', 'NumberTitle', 'off');
            obj.ax = axes(obj.fig);
            hold(obj.ax, 'on');
            colormap parula;
            colorbar;

            obj.Z = nan(length(axis1), length(axis2));
            
            obj.contourPlot = [];
            xlabel(obj.ax, 'Aux1 (V)');
            ylabel(obj.ax, 'Aux2 (V)');
            title(obj.ax, 'SR830');
            legend(obj.ax, 'show');
            grid(obj.ax, 'on');
            
            

        end
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
            addpoints(obj.lines.voltage, voltage, R);
            % addpoints(obj.lines.R,R);
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
