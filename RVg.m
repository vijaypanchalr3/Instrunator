addpath(genpath('Instrunator'));

keith = keithley2400(24);
pause(0.1);
lockin = sr830(8);
try

    
    pause(0.1);
    keith.enableOutput();
    pause(0.1);
    keith.modeVoltage();
    pause(0.1);
    keith.setVoltageCompliance(21);
    pause(0.1);
    keith.setCurrentCompliance(1.05e-4);
    pause(0.1);
    keith.setVoltage(0);
    pause(0.1);
    
    sampler = SR830Sampler(lockin, 0.1);
    
    data = sampler.test_voltage_sweep(keith, [-1,1,0.1],[-1,1,0.1]);
    keith.disconnect();
    lockin.disconnect();
catch ME
    keith.disconnect();
    lockin.disconnect();
    error("Failed to connect to SR830: %s", ME.message);
end