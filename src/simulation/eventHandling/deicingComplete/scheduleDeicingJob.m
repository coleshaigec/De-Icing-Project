function simContext = scheduleDeicingJob(simContext, aircraftID, startTime, serverIndex, serviceProcess)
    % SCHEDULEDEICINGJOB Schedules a deicing completion event for a specified aircraft.
    
    % -- Assign aircraft to specified deicing server --
    simContext.state.deicingServers(serverIndex).isBusy = true;
    simContext.state.deicingServers(serverIndex).currentAircraftId = aircraftID;
    simContext.state.deicingServers(serverIndex).currentServiceStartTime = startTime;

    % -- Find aircraft inside state tracker --
    [idxAircraft, aircraft] = findAircraftById(simContext.state, aircraftID);
    
    % -- Validation --
    assert(~isempty(idxAircraft), ...
    'scheduleDeicingJob:AircraftNotFound', ...
    'Aircraft ID not found in state tracker.');

    assert(serviceProcess.muDI > 0, ...
        'scheduleDeicingJob:InvalidServiceRate', ...
        'serviceProcess.muDI must be positive.');
    
    assert(serviceProcess.Cs > 0, ...
        'scheduleDeicingJob:InvalidServiceCV', ...
        'serviceProcess.Cs must be positive.');
    
    assert(aircraft.serviceProcessCVMultiplier > 0, ...
        'scheduleDeicingJob:InvalidAircraftCVMultiplier', ...
        'Aircraft serviceProcessCVMultiplier must be positive.');
    
    assert(aircraft.meanServiceTimeMultiplier > 0, ...
        'scheduleDeicingJob:InvalidAircraftMeanMultiplier', ...
        'Aircraft meanServiceTimeMultiplier must be positive.');

    % -- Use Gamma distribution parameters from aircraft and service process to sample service time --
    serviceProcessCV = serviceProcess.Cs;
    serviceProcessMeanRate = serviceProcess.muDI;
    meanServiceTime = 1 / serviceProcessMeanRate;

    effectiveCV = serviceProcessCV * aircraft.deicingServiceProcessCVMultiplier;
    effectiveMeanServiceTime = meanServiceTime * aircraft.meanDeicingServiceTimeMultiplier;

    serviceTimeAlpha = 1 / effectiveCV^2;
    serviceTimeTheta = effectiveCV ^ 2 * effectiveMeanServiceTime;
    
    deicingServiceTime = gamrnd(serviceTimeAlpha, serviceTimeTheta);

    % -- Schedule de-icing completion event and add to event calendar --
    deicingCompletionEvent = buildTemplateEventStruct();
    deicingCompletionEvent.time = startTime + deicingServiceTime;
    deicingCompletionEvent.type = "deicingComplete";
    deicingCompletionEvent.aircraftID = aircraftID;
    deicingCompletionEvent.serverID = serverIndex;
    simContext.eventCalendar = pushEventToCalendar(simContext.eventCalendar, deicingCompletionEvent);

    % -- Update aircraft state --
    simContext.state.aircraft(idxAircraft).currentDeicingServiceStartTime = startTime;
end