% Author: Angelo G. Gaillet
% Release date: 31/07/2022
%
% This class allows for simulation of common sensor failures

classdef failureSimulator

    properties (Access = private)
        failureType;
        offset;
        lambda;
        sigma;
        tError;
        gain;
        value;
        likelihood;
        alsoNegSpikes;
        severity;
        randomSpikeAmpl;
        satMax;
        satMin;
        saturateFlag;

        frozenValue;
    end

    methods

        function obj = failureSimulator()
            obj.reset();
        end

        function obj = reset(obj)
            obj.failureType = 'None';
            obj.offset = 0;
            obj.lambda = 0;
            obj.sigma = 0;
            obj.tError = 0;
            obj.gain = 1;
            obj.value = 0;
            obj.likelihood = 0;
            obj.alsoNegSpikes = false;
            obj.severity = 0;
            obj.randomSpikeAmpl = false;
            obj.satMax = inf;
            obj.satMin = -inf;
            obj.saturateFlag = false;

            obj.frozenValue = nan;
        end

        function obj = setErrorTime(obj, startTimestamp)
            if startTimestamp >= 0
                obj.tError = startTimestamp;
            else
                error('Time needs to be positive')
            end
        end

        function [obj, sensorData] = applyFailure(obj, sensorData, timestamp)
            for i = 1:length(timestamp)
                if timestamp(i) >= obj.tError
                    switch obj.failureType
                        case 'Bias'
                            %Add fixed bias to all dimensions
                            sensorData(i) = sensorData(i) + obj.offset;
                        case 'Drift'
                            sensorData(i) = sensorData(i) + obj.lambda * (timestamp(i) - obj.tError);
                        case 'Degradation'
                            sensorData(i) = sensorData(i) - obj.sigma + 2*obj.sigma*rand;
                        case 'Freezing'
                            if timestamp(i) == obj.tError
                                obj.frozenValue = sensorData(i);
                            end
                            sensorData(i) = obj.frozenValue;
                        case 'CalibrationError'
                            sensorData(i) = sensorData(i)*obj.gain;
                        case 'FixedSpiking'
                            if rand > (1 - obj.likelihood)
                                sensorData(i) = obj.value;
                            end
                        case 'IncrementalSpiking'
                            if rand > (1 - obj.likelihood)
                                if obj.randomSpikeAmpl == true
                                    randVal = rand;
                                else
                                    randVal = 1;
                                end
                                if obj.alsoNegSpikes
                                    sensorData(i) = sensorData(i) -obj.sigma + 2*obj.sigma*randVal;
                                else
                                    sensorData(i) = sensorData(i) +obj.sigma*randVal;
                                end
                            end
                    end

                else
                    if strcmp(obj.failureType, 'Freezing')
                        obj.frozenValue = sensorData(i);
                    end
                end
            end

            if obj.saturateFlag
                sensorData = obj.saturate(sensorData);
            end

        end

        function obj = setOffset(obj, offset)
            obj.offset = offset;
            obj.failureType = 'Bias';
        end

        function obj = setDrift(obj, lambda)
            if (abs(lambda) < 1 || abs(lambda) > 1)
                obj.lambda = lambda;
                obj.failureType = 'Drift';
            else
                error('The drift coefficient must be between -1 and 1');
            end
        end

        function obj = setDegradation(obj, sigma)
            obj.sigma = sigma;
            obj.failureType = 'Degradation';
        end

        function obj = setFreezing (obj)
            obj.failureType = 'Freezing';
        end

        function obj = setCalibrationError(obj, gain)
            obj.gain = gain;
            obj.failureType = 'CalibrationError';
        end

        function obj = setFixedSpiking(obj, value, likelihood)
            if (likelihood > 0 && likelihood  < 1)
                obj.value = value;
                obj.likelihood = likelihood;
                obj.failureType = 'FixedSpiking';
            else
                error('The likelihood must be between 0 and 1')
            end
        end

        function obj = setIncrementalSpiking(obj, sigma, likelihood, severity, alsoNegative, random)
            if islogical(random)
                if islogical(alsoNegative)
                    if (likelihood > 0 && likelihood  < 1)
                        obj.sigma = sigma;
                        obj.likelihood = likelihood;
                        obj.severity = severity;
                        obj.alsoNegSpikes = alsoNegative;
                        obj.failureType = 'IncrementalSpiking';
                        obj.randomSpikeAmpl = random;
                    else
                        error('The likelihood must be between 0 and 1')
                    end
                else
                    error('alsoNegative must be either False (for only positive spikes) or True (for both positive and negative spikes)');
                end
            else
                error('random must be either False (for randomness in the increments) or True (for fixed increments)');
            end
        end

        function obj = setSensorSaturation(obj, min, max)
            obj.satMax = max;
            obj.satMin = min;
            obj.saturateFlag = True;
        end

    end

    methods (Access = private)

        function data = saturate(data)
            data = max(obj.satMin, min(obj.satMax, data));
        end

    end

end