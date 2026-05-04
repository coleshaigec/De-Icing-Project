function simContext = scheduleTaxiTakeoffJob(simContext, aircraftID, startTime, serverIndex)
    % SCHEDULETAXITAKEOFFJOB Schedules taxiComplete event. 

    assert(aircraftID > 0, "Invalid aircraft for taxi/takeoff job: aircraftID must be positive finite scalar.");
    % -- Sample aircraft service time --
    meanTaxiTakeoffServiceTime = simContext.taxiTakeoffProcess.T0;
    taxiTakeoffServiceTimeCV = simContext.taxiTakeoffProcess.CT;

    taxiTakeoffServiceTimeAlpha = 1 / taxiTakeoffServiceTimeCV^2;
    taxiTakeoffServiceTimeTheta = meanTaxiTakeoffServiceTime / taxiTakeoffServiceTimeAlpha;

    taxiTakeoffServiceTimeSample = gamrnd(taxiTakeoffServiceTimeAlpha, taxiTakeoffServiceTimeTheta);

    % -- Build and schedule completion event --
    taxiCompleteEvent = buildTemplateEventStruct();
    taxiCompleteEvent.time = startTime + taxiTakeoffServiceTimeSample;
    taxiCompleteEvent.type = "taxiComplete";
    taxiCompleteEvent.aircraftID = aircraftID;
    taxiCompleteEvent.serverID = serverIndex;

    simContext.eventCalendar = pushEventToCalendar(simContext.eventCalendar, taxiCompleteEvent);
    
    % -- Update aircraft state --
    [idxAircraft, ~] = findAircraftById(simContext.state, aircraftID);
    assert(~isempty(idxAircraft), ...
    'scheduleTaxiTakeoffJob:AircraftNotFound', ...
    'Aircraft ID %d not found in state tracker.', aircraftID);

    taxiQueueingDelay = startTime - ...
    simContext.state.aircraft(idxAircraft).currentDeicingServiceCompletionTime;
    
    assert(taxiQueueingDelay >= -1e-9, ...
        'scheduleTaxiTakeoffJob:NegativeTaxiQueueingDelay', ...
        'Negative taxi queueing delay for aircraft %d.', aircraftID);
    
    simContext.state.aircraft(idxAircraft).totalTaxiTakeoffQueueingDelay = ...
        simContext.state.aircraft(idxAircraft).totalTaxiTakeoffQueueingDelay + ...
        max(taxiQueueingDelay, 0);

    simContext.state.aircraft(idxAircraft).currentTaxiTakeoffStartTime = startTime;
    simContext.state.aircraft(idxAircraft).totalTaxiTakeoffServiceTime = ...
        simContext.state.aircraft(idxAircraft).totalTaxiTakeoffServiceTime + ...
        taxiTakeoffServiceTimeSample;

    % -- Update server state -- 
    simContext.state.taxiTakeoffServers(serverIndex).isBusy = true;
    simContext.state.taxiTakeoffServers(serverIndex).currentAircraftId = aircraftID;
    simContext.state.taxiTakeoffServers(serverIndex).currentServiceStartTime = startTime;
end