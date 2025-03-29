classdef SR830Sampler < handle
    properties
        lockin         % SR830 instance
        settleTime
        data           % Data storage (struct)
        isRunning      % Control flag for stopping
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
        function obj = SR830Sampler(lockin, settleTime)
            obj.lockin = lockin;
            obj.settleTime = settleTime;
            obj.isRunning = false;

            % Initialize data storage
            obj.data.Aux1 = [];
            % obj.data.Aux2 = [];
            obj.data.X = [];
            obj.data.Y = [];

            % Setup plotting
            obj.initPlot();
        end
        
        %% Start Sampling & Plotting
        function data = Aux1R(obj, startVoltage, rampRate, endVoltage)
            obj.isRunning = true;
            for voltage = startVoltage:rampRate:endVoltage
                obj.lockin.Aux1(voltage);
                % Wait for system to stabilize
                pause(obj.settleTime);
                % Read input voltage (magnitude of signal, "R" value)
                R = obj.lockin.getR();
                pause(obj.settleTime);
                % Store data
                obj.data.Aux1Voltage(end+1) = voltage;
      
                obj.data.InputVoltage(end+1) = R;
                obj.updatePlot(voltage, R);
                fprintf('Aux1 Voltage: %.4f V | Measured Voltage: %.10f V\n', voltage, R);
            end
            data = obj.data;
            fprintf("Sampling complete.\n");
        end

        function data = voltage_sweep(obj, Voltage1, Voltage2)
            obj.isRunning = true;
            if nargin < 2
                obj.initPlot();
                for v1 = Voltage1(1):Voltage1(3):Voltage1(2)
                    obj.lockin.setAux1(v1);

                    pause(obj.settleTime);
                    
                    X = obj.lockin.getX();
                    Y = obj.lockin.getY();

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

                obj.init2DPlot(mV1);
                %CONFUSED HERE: HOW TO GET OVER WITH THIS MESHING AND DIRECTLY USING IT THERE.
                i = 1;
                j = 1;
                for v1 = Voltage1(1):Voltage1(3):Voltage1(2)
                    obj.lockin.setAux1(v1);
                    for v2 = Voltage2(1):Voltage2(3):Voltage2(2)
                        obj.lockin.setAux2(v2);
                        
                        pause(obj.settleTime);
                        
                        X = obj.lockin.getX();
                        Y = obj.lockin.getY();

                        obj.data.Aux2(end+1) = v2;
                        obj.data.X(end+1) = X;
                        obj.data.Y(end+1) = Y;
                        
                        obj.Z(i,j) = sqrt(X^2+Y^2)
                        j = j+1;
                        fprintf('Aux1: %.4f V | Aux2: %.4f V | X: %.10f V\n | Y: %.10f V\n', v1, v2, X, Y);
                    end
                    obj.data.Aux1(end+1) = v1;
                    obj.contourPlot = contourf(V, T, obj.Z, 20, 'LineColor', 'none');
                    i=i+1;
                end
                data = obj.data;
                fprintf("Sampling complete.\n");
            end  
        end

        function data = test_voltage_sweep(obj, keithley, Voltage1, Voltage2)
            obj.isRunning = true;
            meshV1 = linspace(Voltage1(1), Voltage1(2), Voltage1(3));
            meshV2 = linspace(Voltage2(1), Voltage2(2), Voltage2(3));
            [mV1, mV2] = meshgrid(meshV1, meshV2);

            % obj.init2DPlot(mV1);
            %CONFUSED HERE: HOW TO GET OVER WITH THIS MESHING AND DIRECTLY USING IT THERE.
            i = 1;
            j = 1;
            for v1 = Voltage1(1):Voltage1(3):Voltage1(2)
                keithley.setVoltage(v1);
                pause(0.1)
                out = keithley.readAll();
                fprintf("%e", out);
                for v2 = Voltage2(1):Voltage2(3):Voltage2(2)
                    obj.lockin.setAux2(v2);
                    
                    pause(obj.settleTime);
                    
                    X = obj.lockin.getX();
                    Y = obj.lockin.getY();

                    obj.data.Aux2(end+1) = v2;
                    obj.data.X(end+1) = X;
                    obj.data.Y(end+1) = Y;
                    
                    obj.Z(i,j) = sqrt(X^2+Y^2);
                    j = j+1;
                    fprintf('Aux1: %.4f V | Aux2: %.4f V | X: %.10f V | Y: %.10f V\n', v1, v2, X, Y);
                end
                obj.data.Aux1(end+1) = v1;
                obj.contourPlot = contourf(V, T, obj.Z, 20, 'LineColor', 'none');
                i=i+1;
            end
            data = obj.data;
            fprintf("Sampling complete.\n");
        end

        function data = startovernegstart(obj, keithley, Voltage, filename)
            obj.isRunning = true;
                       
            for v1 = Voltage(1):Voltage(3):Voltage(2)
                keithley.setVoltage(v1);
                pause(0.1)
                out = keithley.readAll();
                fprintf("%e\t", out);
                pause(obj.settleTime);

                X = obj.lockin.getX();
                Y = obj.lockin.getY();

                obj.data.Aux1(end+1) = v1;
                obj.data.X(end+1) = X;
                obj.data.Y(end+1) = Y;
                
                fprintf('\nAux1: %.4f V X: %.10f V | Y: %.10f V\n', v1, X, Y);
            end
            for v1 = Voltage(2):-Voltage(3):-Voltage(2)
                keithley.setVoltage(v1);
                pause(0.1)
                out = keithley.readAll();
                fprintf("%e\t", out);
                pause(obj.settleTime);

                X = obj.lockin.getX();
                Y = obj.lockin.getY();

                obj.data.Aux1(end+1) = v1;
                obj.data.X(end+1) = X;
                obj.data.Y(end+1) = Y;
                
                fprintf('\nAux1: %.4f V X: %.10f V | Y: %.10f V\n', v1, X, Y);
                
            end
            for v1 = -Voltage(2):Voltage(3):Voltage(1)
                keithley.setVoltage(v1);
                pause(0.1)
                out = keithley.readAll();
                fprintf("%e\t", out);
                pause(obj.settleTime);

                X = obj.lockin.getX();
                Y = obj.lockin.getY();

                obj.data.Aux1(end+1) = v1;
                obj.data.X(end+1) = X;
                obj.data.Y(end+1) = Y;
                
                fprintf('\nAux1: %.4f V X: %.10f V | Y: %.10f V\n', v1, X, Y);
                
            end
            % data = obj.data;
            obj.finaldata = cell2mat(struct2cell(obj.data));
            obj.finaldata = transpose(obj.finaldata);
            data = obj.finaldata;
            obj.savefile(filename, data);
            fprintf("Sampling complete.\n");
        end


        
        %% Stop Sampling
        function stop(obj)
            obj.isRunning = false;
            fprintf("Sampling stopped.\n");
        end
        
        %% Initialize Live Plot
        function init2Dplot(obj, axis1)
            obj.fig = figure('Name', 'SR830 Data Logger', 'NumberTitle', 'off');
            obj.ax = axes(obj.fig);
            hold(obj.ax, 'on');
            colormap parula;
            colorbar;

            obj.Z = nan(size(axis1));
            
            obj.contourPlot = [];

            
            

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
