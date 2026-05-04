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
    if typeSample <= probabilityThresholds(1)
        idxType = 1;
    elseif typeSample <= probabilityThresholds(2)
        idxType = 2;
    elseif typeSample <= probabilityThresholds(3)
        idxType = 3;
    else
        idxType = 4;
    end
    aircraftType = aircraftTypeInfo.names(idxType);
    
    % -- Extract type-specific Gamma distribution parameter multipliers --
    aircraftMeanServiceTimeMultiplier = aircraftTypeInfo.deicingServiceTimeMeanMultipliers(idxType);
    aircraftServiceTimeCVMultiplier = aircraftTypeInfo.deicingServiceTimeCVMultipliers(idxType);

    % -- Populate output struct --
    aircraft = buildTemplateAircraftStruct();
    aircraft.id = arrivalEvent.aircraftID;
    aircraft.type = aircraftType;
    aircraft.initialArrivalTime = arrivalEvent.time;
    aircraft.deicingServiceTimeMeanMultiplier = aircraftMeanServiceTimeMultiplier;
    aircraft.deicingServiceTimeCVMultiplier = aircraftServiceTimeCVMultiplier;
    aircraft.currentDeicingQueueEntryTime = arrivalEvent.time;

    aircraft.hotLimit = max(30 / simContext.storm.severity, 15); % heuristic choice for HOT limit
    aircraft.numDeicingCyclesCompleted = 0;
    aircraft.totalDeicingQueueingDelay = 0;
    aircraft.totalDeicingServiceTime = 0;
    aircraft.totalTaxiTakeoffQueueingDelay = 0;
    aircraft.totalTaxiTakeoffServiceTime = 0;

    aircraft.STD = arrivalEvent.time + ...
        getAllowableBaselineGroundSojournTime() * aircraftTypeInfo.groundSojournTimeToleranceMultipliers(idxType);
    aircraft.actualTakeoffTime = NaN;
    aircraft.currentLocation = "deicing";
end