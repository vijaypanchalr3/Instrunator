classdef sampler < handle
    properties
        lockin
        settleTime
        data           % struct
        isRunning      
        finaldata
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
        function obj = sampler(lockin, settleTime)
            obj.lockin = lockin;
            obj.settleTime = settleTime;
            obj.isRunning = false;

            obj.data.Aux1 = [];
            obj.data.Aux2 = [];
            obj.data.X = [];
            obj.data.Y = [];
        end
        
        %% Tools
        function ramp_for_singleSource(obj, source, intial_value, ramp_Step, end_value, funcY)
            pause(obj.settleTime);
            for vol = intial_value:ramp_Step:end_value
                source.setVoltage(v1);
                pause(obj.settleTime);
                X = obj.lockin.getX();
                Y = obj.lockin.getY();

                obj.data.sourceVoltage(end+1) = voltage;
                obj.data.X(end+1) = X;
                obj.data.Y(end+1) = Y;

                obj.updatePlot(voltage, funcY(X, Y));
            end
        end

        function x = identity(obj, x, y)
            %pass
        end


        %% Sampling for single source
        function data = singleSource(obj, source, Voltage, type, funcY)
            obj.isRunning = true;

            % init vars 
            obj.data.sourceVoltage = [];
            obj.data.X = [];
            obj.data.Y = [];
            initPLotSingle();
            if nargin<4
                funcY = @obj.identity;
            end

            if nargin<3 % Default shit
                % initial --> end
                obj.ramp_for_singleSource(source,Voltage(1), Voltage(3), Voltage(2), funcY);
            end


            if type==3

                fprintf('still Vijay didnt written this');

            elseif type==2
                % initial --> end
                obj.ramp_for_singleSource(source,Voltage(1), Voltage(3), Voltage(2), funcY);
                % end --> -end
                obj.ramp_for_singleSource(source,Voltage(2), -Voltage(3), -Voltage(2), funcY);
                % -end --> initial
                obj.ramp_for_singleSource(source,Voltage(2), Voltage(3), Voltage(1), funcY);
                

            elseif type==1
                % initial --> end
                obj.ramp_for_singleSource(source,Voltage(1), Voltage(3), Voltage(2), funcY);
                % end --> intial
                obj.ramp_for_singleSource(source,Voltage(2), -Voltage(3), Voltage(1), funcY);

            else %default
                % initial --> end
                obj.ramp_for_singleSource(source,Voltage(1), Voltage(3), Voltage(2), funcY);
            end
        
            source.setVoltage(0); %Safety: Don't Remove
            
            data = obj.data;
            fprintf("Sampling complete.\n");
        end
        %% Plots for Single source 
        function initPLotSingle(obj)
            obj.fig = figure('Name', 'SR830 Data Logger', 'NumberTitle', 'off');
            obj.ax = axes(obj.fig);
            hold(obj.ax, 'on');
            
            % Create animated lines for real-time plotting
            obj.lines = animatedline(obj.ax, 'Color', 'r', 'LineWidth', 1.5, 'DisplayName', 'Data');

            xlabel(obj.ax, 'Aux (V)');
            ylabel(obj.ax, 'R (V)');
            title(obj.ax, 'Data logger');
            legend(obj.ax, 'show');
            grid(obj.ax, 'on');
        end

        
        %% Stop Sampling
        function stop(obj)
            obj.isRunning = false;
            fprintf("Sampling stopped.\n");
        end
        

        %% Update Live Plot
        function updatePlot(obj, x, y)
            addpoints(obj.lines, x, y);
            drawnow;
        end
        
        %% Destructor: Cleanup
        function delete(obj)
            obj.stop();
            if isvalid(obj.fig)
                close(obj.fig);
            end
        end

        %% Save file
        function savefile(obj, filename, data)
            count = 1;
            % Check if the file exists and modify the filename
            while isfile(filename)
                newfilename = split(filename,".");
                newfilename = newfilename(1);
                extend =  sprintf('%d.asc', count);
                filename = append(newfilename, extend);
                filename = strjoin(filename);
                count = count + 1;
            end
            % Check if obj has the data field
            % if ~isfield(obj, 'finaldata')
            %     error('The input object does not contain a "data" field.');
            % end

            % Check if data is a numeric matrix
            if ~isnumeric(obj.finaldata)
                error('obj.data must be a numeric matrix.');
            end
            matlabsucks = data;
            save(filename, 'matlabsucks', '-ascii')
            fprintf('Data successfully saved to %s\n', filename);
        
        end
    end
end
