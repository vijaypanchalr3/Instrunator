clc; clear; close all;

% Define grid parameters for the sweep:
n = 20;  % number of voltage and temperature steps
voltage = linspace(0, 10, n);         % Voltage sweep from 0 to 10 V
temperature = linspace(20, 80, n);      % Temperature sweep from 20 to 80 (units)

% Create a mesh grid of voltage and temperature
[V, T] = meshgrid(voltage, temperature);

% Simulated measurement function:
% For example, you could imagine the measurement as:
%   measured_value = sin(voltage) + cos(temperature in radians)
Z_measured = sin(V) + cos(T * pi/180);

% Define a grid for interpolation (finer grid for smoother contour)
[X, Y] = meshgrid(linspace(0, 10, 50), linspace(20, 80, 50));

% Open figure and set up the display
figure;
hold on;
colormap parula;
colorbar;
title('Dynamically Updating Contour Plot (Voltage Sweep)');

% Initialize the contour plot handle
contourPlot = [];

% Flatten the matrices so that we add points one by one in a predetermined order
all_V = V(:);
all_T = T(:);
all_Z = Z_measured(:);

totalPoints = length(all_V);

% Loop over each point as if you are sweeping through the measurement
for idx = 1:totalPoints
    % Collect points up to current index (simulate sequential sweep)
    if idx == 1
        added_V = all_V(idx);
        added_T = all_T(idx);
        added_Z = all_Z(idx);
    else
        added_V = [added_V; all_V(idx)];
        added_T = [added_T; all_T(idx)];
        added_Z = [added_Z; all_Z(idx)];
    end
    
    % Only update if we have at least 4 points (to avoid collinearity)
    if idx >= 4
        % Interpolate the measured data onto the defined grid
        Z_interp = griddata(added_V, added_T, added_Z, X, Y, 'cubic');
        
        % Check that the interpolation returned some valid data
        if ~all(isnan(Z_interp(:)))
            % Delete the previous contour if it exists and is valid
            if ~isempty(contourPlot) && all(arrayfun(@isgraphics, contourPlot))
                delete(contourPlot);
            end
            % Draw the updated contour plot
            contourPlot = contourf(X, Y, Z_interp, 20, 'LineColor', 'none');
        end
    end
    
    drawnow;
    pause(0.1); % pause to simulate delay in measurement (voltage sweep)
end

disp('Done dynamically building contour.');
