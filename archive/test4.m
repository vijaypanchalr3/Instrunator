clc; clear; close all;
% myModulePath = 'C:\Users\vijay\Projects\MATLAB\dynamic_plot.py';
% if count(py.sys.path, myModulePath) == 0
%     insert(py.sys.path, int32(0), myModulePath);
% end
% Ensure MATLAB is configured to use the correct Python interpreter
% You can check with:
pyenv(Version="C:\Users\vijay\Projects\MATLAB\env\Scripts\python.exe");
pyversion;

% Generate some example data (simulate a voltage sweep or any dynamic process)
n = 50; % grid size
data = nan(n);  % initialize a data matrix

% Create a figure in MATLAB for log or additional display if needed
% figure;
hImg = imagesc(data);
% colorbar;
% title('MATLAB Display (for reference)');

% Simulate dynamic data update (for example, updating row by row)
for idx = 1:n
    % Update one row of data (for example, a sine wave pattern across the row)
    data(idx,:) = sin(linspace(0, 2*pi, n)) + idx/n;
    
    % Optionally update MATLAB figure to monitor progress
    % set(hImg, 'CData', data);
    % drawnow;
    
    % Convert MATLAB matrix to a Python object (numpy array)
    % MATLAB automatically converts numeric arrays to numpy arrays if Python is configured.
    py.dynamic_plot.update_plot(data);
    
    pause(0.1); % simulate delay between measurements
end

disp('Data feed complete.');
