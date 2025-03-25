% addpath(genpath('Instrunator'))

clear; clc; clearvars;

%% User-defined parameters
gpibAddress = 8;       % GPIB address of the SR830 (update if needed)
startVoltage = 0;      % Initial voltage for Aux1 output (V)
endVoltage = 1;        % Final voltage for Aux1 output (V)
rampRate = 0.01;       % Voltage step size (V)
settleTime = 0.2;      % Wait time between steps (s)
% voltage1 = (-1,1,0.2);

%% Machine
% lockin1 = sr830(8);

sampler = toySR830Sampler(NaN(0), settleTime);
data = sampler.voltage_sweep([-1,1,0.2], [-1,1,0.2]);

% lockin1.disconnect();

