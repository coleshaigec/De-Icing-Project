function aircraft = constructAircraft(arrivalEvent, simContext)
    % CONSTRUCTAIRCRAFT Instantiates aircraft entity arising from arrival event.
    %
    % OUTPUT
    %  aircraft struct with fields

    % -- Get global type info --
    aircraftTypeInfo = getAircraftTypeInfo();
    probabilityThresholds = cumsum(aircraftTypeInfo.probabilities);

    %  -- Pick aircraft type by random sampling --
    typeSample = rand(1);
    if isbetween(typeSample, 0, probabilityThresholds(1))
        idxType = 1;
    elseif isbetween(typeSample, probabilityThresholds(1), probabilityThresholds(2))
        idxType = 2;
    elseif isbetween(typeSample, probabilityThresholds(2), probabilityThresholds(3))
        idxType = 3;
    else
        idxType = 4;
    end
    aircraftType = aircraftTypeInfo.names(idxType);
    
    % -- Extract type-specific Gamma distribution parameter multipliers --
    aircraftMeanServiceTimeMultiplier = aircraftTypeInfo.serviceTimeMeanMultipliers(idxType);
    aircraftServiceTimeCVMultiplier = aircraftTypeInfo.serviceTimeCVMultipliers(idxType);

    % -- Populate output struct --
    aircraft = buildTemplateAircraftStruct();
    aircraft.id = arrivalEvent.aircraftID;
    aircraft.type = aircraftType;
    aircraft.initialArrivalTime = arrivalEvent.time;
    aircraft.serviceTimeMeanMultiplier = aircraftMeanServiceTimeMultiplier;
    aircraft.serviceTimeCVMultiplier = aircraftServiceTimeCVMultiplier;
    aircraft.currentDeicingQueueEntryTime = arrivalEvent.time;

    aircraft.hotLimit = max(30 / simContext.storm.severity, 15); % heuristic choice for HOT limit
    aircraft.numDeicingCyclesCompleted = 0;
    aircraft.STD = arrivalEvent.time + ...
        getAllowableBaselineGroundSojournTime() * aircraftTypeInfo.groundSojournTimeToleranceMultipliers(idxType);
    aircraft.actualTakeoffTime = NaN;
    aircraft.currentLocation = "deicing";
end