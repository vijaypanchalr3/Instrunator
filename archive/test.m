clc; clear; close all;

% Initialize data storage
added_x = [];
added_y = [];
added_z = [];

% Create figure
figure;
hold on;
colormap parula;
colorbar;
title('Dynamically Updating Contour Plot');

% Define grid for interpolation
[X, Y] = meshgrid(linspace(-5, 5, 50), linspace(-5, 5, 50));

% Initialize contour plot handle
contourPlot = [];

% Number of points to add dynamically
numPoints = 100;
new_x = 0;
new_y = 0;
for i = 1:numPoints
    % Generate new random point
    new_x = new_x+1; % Random x in [-5,5]
    new_y = new_y+1; % Random y in [-5,5]
    new_z = sin(new_x) * cos(new_y); % Example function

    % Store new point
    added_x = [added_x, new_x];
    added_y = [added_y, new_y];
    added_z = [added_z, new_z];

    % Ensure we have at least 4 points before interpolation
    if length(added_x) >= 4
        % Interpolate data for contour
        Z = griddata(added_x, added_y, added_z, X, Y, 'cubic');

        % Ensure Z is valid (not all NaNs)
        if ~all(isnan(Z(:)))
            % Delete old contour only if it exists and is a valid graphics object
            % if ~isempty(contourPlot) && all(isgraphics(contourPlot))
            %     delete(contourPlot);
            % end
            % Update contour plot
            contourPlot = contourf(X, Y, Z, 20, 'LineColor', 'none');
        end
    end

    drawnow;
    pause(0.1); % Simulate dynamic update delay
end

disp('Done dynamically building contour.');
