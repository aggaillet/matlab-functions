classdef failureSimulator
    %This class allows for simulation of common sensor failures

    properties (Access = private)
        failureType;
        offset;
        lambda;
        sigma;
        t0;
        tError;
        gain;
        value;
        likelihood;
        alsoNegSpikes;
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
            obj.t0 = -1;
            obj.tError = 0;
            obj.gain = 1;
            obj.value = 0;
            obj.likelihood = 0;
            obj.alsoNegSpikes = False;
            obj.randomSpikeAmpl = False;
            obj.satMax = inf;
            obj.satMin = -inf;
            obj.saturateFlag = False;

            obj.frozenValue = nan;
        end

        function obj = setErrorTime(startTimestamp)
            if startTimestamp > 0
                obj.tError = startTimestamp;
            else
                error('Time cannot be negative')
            end
        end

        function [obj, sensorData] = applyFailure(obj, sensorData, timestamp)
            if timestamp >= obj.tError
                switch obj.failureType
                    case 'Bias'
                        %Add fixed bias to all dimensions
                        sensorData = sensorData + obj.offset;
                    case 'Drift'
                        sensorData = sensorData + obj.lambda * (timestamp - obj.t0);
                    case 'Degradation'
                        sensorData = sensorData - obj.sigma + 2*obj.sigma*rand;
                    case 'Freezing'
                        sensorData = obj.frozenValue;
                    case 'CalibrationError'
                        sensorData = sensorData*obj.gain;
                    case 'FixedSpiking'
                        if rand > (1 - obj.likelihood)
                            sensorData = obj.value;
                        end
                    case 'IncrementalSpiking'
                        if rand > (1 - obj.likelihood)
                            if obj.randomSpikeAmpl == true
                                randVal = rand;
                            else
                                randVal = 1;
                            end
                            if obj.alsoNegSpikes
                                sensorData = sensorData -obj.sigma * 2*obj.sigma*randVal;
                            else
                                sensorData = sensorData +obj.sigma*randVal;
                            end
                        end
                end

            else
                if strcmp(obj.failureType, 'Freezing')
                    obj.frozenValue = sensorData;
                end
            end

            sensorData = saturate(sensorData);

        end

        function obj = setOffset(obj, offset)
            obj.offset = offset;
            obj.failureType = 'Bias';
        end

        function obj = setDrift(obj, lambda, startTimestamp)
            if (abs(lambda) < 0.1 && abs(lambda) > 0)
                if (startTimestamp > 0)
                    obj.lambda = lambda;
                    obj.t0 = startTimestamp;
                    obj.failureType = 'Drift';
                else
                    error('Time cannot be negative');
                end
            else
                error('The drift coefficient must be between -0.1 and 0.1');
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
            if isboolean(random)
                if isboolean(alsoNegative)
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