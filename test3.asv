clc; clear; close all;

% Define grid parameters for the sweep:
n = 20;  % number of voltage and temperature steps
voltage = linspace(0, 10, n);         % Voltage sweep from 0 to 10 V
temperature = linspace(20, 80, n);      % Temperature sweep from 20 to 80 units

% Create a mesh grid of voltage and temperature (measurement grid)
[V, T] = meshgrid(voltage, temperature);

% Simulated measurement function:
% For example: measured_value = sin(voltage) + cos(temperature in radians)
Z_measured = sin(V) + cos(T * pi/180);

% Create an empty matrix for measurements (initialize as NaN)
Z = nan(size(V));

% Open figure and set up display
figure;
hold on;
colormap parula;
colorbar;
title('Dynamically Updating Contour Plot (Voltage Sweep)');

% Initialize contour plot handle
contourPlot = [];

% Total number of points in the grid
totalPoints = numel(V);

% We'll update the grid sequentially (row-wise order)
for idx = 1:totalPoints
    % Determine the row and column indices for the current measurement
    [row, col] = ind2sub(size(V), idx);
    
    % Update the measurement matrix with the new data point
    Z(row, col) = rand();
    
    % Only update the contour if at least a few points have been measured
    if sum(~isnan(Z(:))) >= 4
        % If an existing contour plot exists and is valid, delete it
        if ~isempty(contourPlot)
            if all(isgraphics(contourPlot(:)))
                delete(contourPlot);
            end
        end
        
        % Update contour plot with the new data matrix.
        % Note: Even if many values are still NaN, contourf will plot based on available data.
        contourPlot = contourf(V, T, Z, 20, 'LineColor', 'none');
    end
    
    drawnow;
    pause(0.1); % simulate delay in measurement (voltage sweep)
end

disp('Done dynamically updating contour.');
