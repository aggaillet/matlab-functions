clearvars
close all
clc

signal.timestamps = 0:0.1:20;

signal.original = sin(signal.timestamps);
sim = failureSimulator();
sim = sim.setErrorTime(0);

sim = sim.setOffset(1);
[sim, signal.bias] = sim.applyFailure(signal.original, signal.timestamps);
sim = sim.reset;
sim = sim.setCalibrationError(1.5);
[sim, signal.calibration] = sim.applyFailure(signal.original, signal.timestamps);
sim = sim.reset;
sim = sim.setDegradation(0.5);
[sim, signal.degradation] = sim.applyFailure(signal.original, signal.timestamps);
sim = sim.reset;
sim = sim.setDrift(0.1);
[sim, signal.drift] = sim.applyFailure(signal.original, signal.timestamps);
sim = sim.reset;
sim = sim.setFreezing;
[sim, signal.freezing] = sim.applyFailure(signal.original,signal.timestamps);
sim = sim.reset;
sim = sim.setFixedSpiking(0.8, 0.05);
[sim, signal.fixedSpiking] = sim.applyFailure(signal.original, signal.timestamps);
sim = sim.reset;
sim = sim.setIncrementalSpiking(0.8, 0.05, 0.5, true, true);
[sim, signal.incrementalSpiking] = sim.applyFailure(signal.original, signal.timestamps);

figure();
hold;
plot(signal.timestamps, signal.original);
plot(signal.timestamps, signal.bias);
plot(signal.timestamps, signal.calibration);
plot(signal.timestamps, signal.degradation);
plot(signal.timestamps, signal.drift);
plot(signal.timestamps, signal.freezing);
plot(signal.timestamps, signal.fixedSpiking);
plot(signal.timestamps, signal.incrementalSpiking);
legend('original', 'bias', 'calibration', 'degradation', 'drift', 'freezing', 'fixedSpiking', 'incrSpiking');