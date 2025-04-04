classdef sampler < handle
    properties
        lockin
        settleTime
        data           % struct
        isRunning      
        finaldata
        rampStep
        rampDelay
        dataPath
        fileSaved
    end
    
    properties (Access = private)
        fig            % Figure for plotting
        ax             % Axes for plotting
        lines          % Animated lines
        contourPlot
    end
    
    methods
        %% Constructor: Initialize Sampler
        function obj = sampler(lockin, settleTime, rampStep, rampDelay, dataPath)
            arguments
                lockin
                settleTime (1,1) double = 0.3 % Default settle time
                rampStep (1,1) double = 0.01 % Default ramp step
                rampDelay (1,1) double = 0.01 % Default ramp delay
                dataPath (1,:) char = "./" % Default data path
            end
            
            obj.rampDelay = rampDelay;
            obj.rampStep = rampStep;
            obj.lockin = lockin;
            obj.settleTime = settleTime;
            obj.isRunning = false;
            obj.fileSaved = false;
            obj.dataPath = dataPath;

        end

        %% Tools
        function ramp_for_singleSource(obj, source, initial_value, ramp_Step, end_value, funcY)
            arguments
                obj
                source
                initial_value (1,1) double
                ramp_Step (1,1) double
                end_value (1,1) double
                funcY (1,1) function_handle = @obj.identity
            end
            obj.rampSource(source, source.getVoltage(), initial_value);

            init = initial_value;
            for cur = initial_value:ramp_Step:end_value
                obj.rampSource(source, init, cur);
                init = cur;

                OutputXY = obj.lockin.getXY(obj.settleTime);
                obj.data.sourceVoltage(end+1) = cur;
                obj.data.X(end+1) = OutputXY(1);
                obj.data.Y(end+1) = OutputXY(2);
                
                
                obj.updatePlotSingle(cur, funcY(OutputXY(1), OutputXY(2)));
            end
        end

        function rampSource(obj, source, initial_value,end_value)
            arguments
                obj
                source
                initial_value (1,1) double
                end_value (1,1) double
            end

            if initial_value > end_value
                for vol = initial_value:-obj.rampStep:end_value
                    pause(obj.rampDelay);
                    source.setVoltage(vol);
                end
            elseif initial_value < end_value
                for vol = initial_value:obj.rampStep:end_value
                    pause(obj.rampDelay);
                    source.setVoltage(vol);
                end
            else
                % Do nothing
            end    
        end

        function x = identity(obj, x, y)
            arguments
                obj
                x (1,1) double
                y (1,1) double = 1
            end
            %pass
        end

        
        function D = funcD(obj, Vtg, Vbg, Ctg, Cbg, D0)
            arguments
                obj
                Vtg (1,1) double
                Vbg (1,1) double
                Ctg (1,1) double = 1
                Cbg (1,1) double = 1
                D0 (1,1) double = 0
            end
            D = (Ctg*Vtg-Cbg*Vbg)/(2*8.85418e-12) + D0;
        end

        function n = funcn(obj, Vtg, Vbg, Ctg, Cbg, n0)
            arguments
                obj
                Vtg (1,1) double
                Vbg (1,1) double
                Ctg (1,1) double = 1
                Cbg (1,1) double = 1
                n0 (1,1) double = 0
            end
            n = (Ctg*Vtg+Cbg*Vbg)/(2*1.60217e19 ) + n0;
        end

        function filename = getQuittingFilename(obj)
            filename = append(obj.dataPath, "Quited_", datetime("yyyymmdd"), ".asc");
        end


        %% Sampling for single source
        function data = singleSource(obj, source, Voltage, type, filename, funcY)
            arguments
                obj
                source
                Voltage (1,3) double
                type (1,1) int8 = 0
                filename (1,:) char = append(obj.dataPath, "SingleGated", datestr(datetime('now'), 'yyyymmdd'), ".asc");
                funcY (1,1) function_handle = @obj.identity
            end

            obj.isRunning = true;

            % init vars 
            obj.data.sourceVoltage = [];
            obj.data.X = [];
            obj.data.Y = [];

            % init plot
            obj.initPLotSingle();


            if type==3

                fprintf('still Vijay didnt written this, he is lazy\n');

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
        
            obj.rampSource(source, source.getVoltage(), 0) %Safety: Don't Remove

            obj.finaldata = cell2mat(struct2cell(obj.data));
            obj.finaldata = transpose(obj.finaldata);
            data = obj.finaldata;
            obj.savefile(filename, data);
            fprintf("Sampling complete.\n");
            obj.fileSaved = true;
            obj.stop()
        end

        %% Plots for Single source 
        function initPLotSingle(obj)
            obj.fig = figure('Name', 'SR830 Data Logger', 'NumberTitle', 'off');
            obj.ax = axes(obj.fig);
            hold(obj.ax, 'on');
            
            % Create animated lines
            obj.lines = animatedline(obj.ax, 'Color', 'r', 'LineWidth', 1.5, 'DisplayName', 'Data');

            xlabel(obj.ax, 'Aux (V)');
            ylabel(obj.ax, 'R (V)');
            title(obj.ax, 'Data logger');
            legend(obj.ax, 'show');
            grid(obj.ax, 'on');
        end
        
        
        function updatePlotSingle(obj, x, y)
            addpoints(obj.lines, x, y);
            drawnow;
        end

        function data = doubleSource(obj, source1, source2, Voltage1, Voltage2, options, functions)
            arguments
                obj
                source1
                source2
                Voltage1 (1,3) double
                Voltage2 (1,3) double
                options.type (1,1) int8 = 0
                options.filename (1,:) string = ""
                functions.functionXY (1,1) function_handle = @obj.identity
                functions.functionD (1,1) function_handle = @obj.identity
                functions.functionn (1,1) function_handle = @obj.identity
            end
            obj.isRunning = true;

            % init vars 
            obj.data.sourceVoltage1 = [];
            obj.data.sourceVoltage2 = [];
            obj.data.X = [];
            obj.data.Y = [];
            v1_ = Voltage1(1):Voltage1(3):Voltage1(2);
            v2_ = Voltage2(1):Voltage2(3):Voltage2(2);
            
            [V1_, V2_] = meshgrid(v1_, v2_);
            index_i=1;
            index_j=1;
            Z = nan(size(V1_));
            obj.initPlotDouble();

            if options.type==1
                % pass
            elseif options.type==0 || nargin<5 % Default
                v1_init = Voltage1(1);
                obj.rampSource(source1, source1.getVoltage(), v1_init);
                for v1 = Voltage1(1):Voltage1(3):Voltage1(2)
                    obj.rampSource(source1, v1_init, v1);
                    obj.lockin.autoSens();
                    v1_init = v1;
                    v2_init = Voltage2(1);
                    [row, col] = ind2sub(size(V1_), index_i);
                    index_i = index_i+1;
                    obj.rampSource(source2, source2.getVoltage(), v2_init);
                    for v2 = Voltage2(1):Voltage2(3):Voltage2(2)
                        obj.rampSource(source2, v2_init, v2);
                        obj.lockin.autoSens();
                        v2_init = v2;
        
                        OutputXY = obj.lockin.getXY(obj.settleTime);
                        Z(row,index_j) = OutputXY(1);
                        index_j = index_j+1;
                        obj.data.sourceVoltage1(end+1) = v1;
                        obj.data.sourceVoltage2(end+1) = v2;
                        obj.data.X(end+1) = OutputXY(1);
                        obj.data.Y(end+1) = OutputXY(2);
                        fprintf("Voltage1: %.2f, Voltage2: %.2f\n", v1, v2);
                    end
                    index_j = 1;
                    if sum(~isnan(Z(:))) >= 4
                        % If an existing contour plot exists and is valid, delete it
                        if ~isempty(obj.contourPlot)
                            if all(isgraphics(obj.contourPlot(:)))
                                delete(obj.contourPlot);
                            end
                        end
                        
                        % Update contour plot with the new data matrix.
                        % Note: Even if many values are still NaN, contourf will plot based on available data.
                        obj.contourPlot = contourf(V1_, V2_, Z, 20, 'LineColor', 'none');
                    end
                end
            end
            obj.rampSource(source1, source1.getVoltage(), 0); %Safety: Don't Remove
            obj.rampSource(source2, source2.getVoltage(), 0); %Safety: Don't Remove

            % Save data to file
            obj.finaldata = cell2mat(struct2cell(obj.data));
            obj.finaldata = transpose(obj.finaldata);
            data = obj.finaldata;
            obj.savefile(options.filename, data);
            fprintf("Sampling complete.\n");
            obj.fileSaved = true;
            obj.stop()

        end

        function initPlotDouble(obj)
            obj.fig = figure('Name', 'SR830 Data Logger', 'NumberTitle', 'off');
            hold on;
            colormap parula;
            colorbar;
            title('SR830 Data Logger');
            xlabel('V1');
            ylabel('V2');
            obj.contourPlot = [];
        end

        function updatePlotDouble(obj, x, y)
            addpoints(obj.lines, x, y);
            drawnow;
        end



        %% Stop Sampling
        function stop(obj)
            obj.isRunning = false;
            fprintf("Sampling stopped.\n");
            if ~obj.fileSaved
                obj.finaldata = cell2mat(struct2cell(obj.data));
                obj.finaldata = transpose(obj.finaldata);
                obj.savefile(filename, obj.finaldata);
                fprintf("Data saved to %s\n", filename);
                obj.fileSaved = true;
            end
        end
        
        %% Cleanup
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
            
            if ~isnumeric(obj.finaldata)
                error('obj.data must be a numeric matrix.');
            end
            matlabsucks = data;
            save(filename, 'matlabsucks', '-ascii')
            fprintf('Data successfully saved to %s\n', filename);
        
        end
    end
end
