function simContext = handleHOTViolatorArrival(simContext, hotViolatorArrivalEvent)
    % HANDLEHOTVIOLATORARRIVAL Handles return of HOT violator to de-icing.

    % Get HOT violator aircraft and set location
    [idxHOTViolatorAircraft, hotViolatorAircraft] = findAircraftById(simContext.state, hotViolatorArrivalEvent.aircraftID);
    hotViolatorAircraft.currentLocation = "deicing";
    simContext.state.aircraft(idxHOTViolatorAircraft) = hotViolatorAircraft;
    
    % -- Check for an available de-icing server and move the aircraft accordingly --
    idleIdx = find(~[simContext.state.deicingServers.isBusy], 1, 'first');
    
    if ~isempty(idleIdx)
        % Empty server detected - schedule deicing job
        simContext = scheduleDeicingJob(simContext, hotViolatorArrivalEvent.aircraftID, ...
            hotViolatorArrivalEvent.time, idleIdx, simContext.serviceProcess);
    else 
        % No available server detected - enqueue the aircraft
        simContext.state.deicingQueue = pushAircraftToDeicingQueue( ...
            simContext.state.deicingQueue, hotViolatorArrivalEvent.aircraftID);
        hotViolatorAircraft.currentDeicingQueueEntryTime = hotViolatorArrivalEvent.time;
        simContext.state.aircraft(idxHOTViolatorAircraft) = hotViolatorAircraft;
    end
end