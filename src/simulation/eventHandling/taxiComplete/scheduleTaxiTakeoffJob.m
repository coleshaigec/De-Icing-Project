function simContext = scheduleTaxiTakeoffJob(simContext, aircraftID, startTime, serverIndex)
    % SCHEDULETAXITAKEOFFJOB Schedules taxiComplete event. 
    
    % -- Sample aircraft service time --
    meanTaxiTakeoffServiceTime = simContext.taxiTakeoffProcess.T0;
    taxiTakeoffServiceTimeCV = simContext.taxiTakeoffProcess.CT;

    taxiTakeoffServiceTimeAlpha = 1 / taxiTakeoffServiceTimeCV^2;
    taxiTakeoffServiceTimeTheta = meanTaxiTakeoffServiceTime / taxiTakeoffServiceTimeAlpha;

    taxiTakeoffServiceTimeSample = gamrnd(taxiTakeoffServiceTimeAlpha, taxiTakeoffServiceTimeTheta);

    % -- Build and enqueue completion event --
    taxiCompleteEvent = buildTemplateEventStruct();
    taxiCompleteEvent.time = startTime + taxiTakeoffServiceTimeSample;
    taxiCompleteEvent.type = "taxiComplete";
    taxiCompleteEvent.aircraftID = aircraftID;
    taxiCompleteEvent.serverID = serverIndex;

    simContext.eventCalendar = pushEventToCalendar(simContext.eventCalendar, taxiCompleteEvent);
    
    % -- Update aircraft state --
    [idxAircraft, aircraft] = findAircraftById(simContext.state, aircraftID);
    aircraft.currentTaxiTakeoffStartTime = startTime;
    simContext.state.aircraft(idxAircraft) = aircraft;

    % -- Update server state -- 
    simContext.state.taxiTakeoffServers(serverIndex).isBusy = true;
    simContext.state.taxiTakeoffServers(serverIndex).currentAircraftId = aircraftID;
    simContext.state.taxiTakeoffServers(serverIndex).currentServiceStartTime = startTime;
end