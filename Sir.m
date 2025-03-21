 %% SR830 Lock-In Amplifier Control Script (GPIB)
% This script ramps the Aux1 output voltage of an SR830 lock-in amplifier
% over a specified range and records the input voltage for each step.

clear; clc;

%% User-defined parameters
gpibAddress = 9;       % GPIB address of the SR830 (update if needed)
startVoltage = 0;      % Initial voltage for Aux1 output (V)
endVoltage = 1;        % Final voltage for Aux1 output (V)
rampRate = 0.01;       % Voltage step size (V)
settleTime = 0.1;      % Wait time between steps (s)

%% Initialize GPIB connection
try
    % Create GPIB object
    lockin = gpib('NI', 0, gpibAddress);
    lockin.InputBufferSize = 256; % Set input buffer size
    lockin.Timeout = 10;          % Timeout for responses (s)

    % Open GPIB connection
    fopen(lockin);
    fprintf('Connected to SR830 at GPIB address %d\n', gpibAddress);
catch ME
    error('Error: Unable to connect to SR830. Check GPIB connection.');
end

%% Initialize data storage
data.Aux1Voltage = [];
data.InputVoltage = [];

%% Ramp Aux1 output voltage and measure input voltage
fprintf('Starting voltage ramp...\n');

for voltage = startVoltage:rampRate:endVoltage
    % Set Aux1 output voltage
    fprintf(lockin, sprintf('AUXV 1, %.4f', voltage));

    % Wait for system to stabilize
    pause(settleTime);

    % Read input voltage (magnitude of signal, "R" value)
    fprintf(lockin, 'OUTP? 3');
    inputVoltage = str2double(fscanf(lockin));

    % Store data
    data.Aux1Voltage(end+1) = voltage;
    data.InputVoltage(end+1) = inputVoltage;

    fprintf('Aux1 Voltage: %.4f V | Measured Voltage: %.6f V\n', voltage, inputVoltage);
end

%% Reset Aux1 output to 0V
fprintf(lockin, 'AUXV 1, 0');
fprintf('Voltage ramp completed. Aux1 output reset to 0V.\n');

%% Close GPIB connection
fclose(lockin);
delete(lockin);
clear lockin;
fprintf('GPIB connection closed.\n');

%% Plot results
figure;
plot(data.Aux1Voltage, data.InputVoltage, '-o', 'LineWidth', 1.5);
xlabel('Aux1 Output Voltage (V)');
ylabel('Measured Input Voltage (V)');
title('Input Voltage vs. Aux1 Output Voltage');
grid on;