function simContext = handleTaxiComplete(simContext, taxiCompleteEvent)
    % HANDLETAXICOMPLETE Handles taxi completion event.

    % MECHANICAL REQUIREMENTS
    % 1. Update server state
    %    - Free up server
    %    - Check if there are jobs in the T/T queue
    %    - If there are, schedule one
    %    - If not, server's current aircraft goes back to NaN
    % 2. Update aircraft state
    %    - Check if aircraft is in HOT violation
    %    - If it is, send it back to de-icing -- helper handles this
    %    - If it isn't, it takes off


    % -- Update server state --
    % If there's no job waiting in the taxi/takeoff queue, free the server
    if isTaxiTakeoffQueueEmpty(simContext.state.taxiTakeoffQueue)
        simContext.state.taxiTakeoffServers(taxiCompleteEvent.serverID).isBusy = false;
        simContext.state.taxiTakeoffServers(taxiCompleteEvent.serverID).currentAircraftId = NaN;
        simContext.state.taxiTakeoffServers(taxiCompleteEvent.serverID).currentServiceStartTime = NaN;
    else 
        % If there's a job waiting, start it and schedule completion
        [nextTaxiTakeoffAircraftID, taxiTakeoffQueue] = popAircraftFromTaxiTakeoffQueue(simContext.state.taxiTakeoffQueue);
        simContext.state.taxiTakeoffQueue = taxiTakeoffQueue;

        simContext = scheduleTaxiTakeoffJob(simContext, nextTaxiTakeoffAircraftID, taxiCompleteEvent.time, taxiCompleteEvent.serverID);
    end

    % -- Update aircraft state -- 
    % Step 1: Check if aircraft is in HOT violation
    [idxTaxiCompleteAircraft, taxiCompleteAircraft] = findAircraftById(simContext.state, taxiCompleteEvent.aircraftID);
    aircraftTaxiTakeoffSojournTime = taxiCompleteEvent.time - taxiCompleteAircraft.currentDeicingServiceCompletionTime;
    isHOTViolation = aircraftTaxiTakeoffSojournTime > taxiCompleteAircraft.hotLimit;

    % Step 2: Handle HOT violators depending on accumulated violation count
    % Aircraft within HOT take off at this point
    if isHOTViolation
        simContext.state.aircraft(idxTaxiCompleteAircraft).numHOTViolations = ...
            simContext.state.aircraft(idxTaxiCompleteAircraft).numHOTViolations + 1;
        
        numHOTViolations = simContext.state.aircraft(idxTaxiCompleteAircraft).numHOTViolations;
        if numHOTViolations > getAllowableHOTViolationsBeforeCancellation()
            % If allowable number of HOT violations exceeded, cancel the flight 
            simContext = cancelFlight(simContext, taxiCompleteEvent.aircraftID);
        else
            % If aircraft is within HOT violation limits, send it back to de-icing
            simContext = scheduleHOTViolatorArrival(simContext, taxiCompleteEvent.aircraftID, taxiCompleteEvent.time);
            taxiCompleteAircraft.currentLocation = "returningToDeicing";
            simContext.state.aircraft(idxTaxiCompleteAircraft) = taxiCompleteAircraft;
        end
    else
        % If aircraft is within HOT, it takes off
        taxiCompleteAircraft.currentLocation = "departed";
        taxiCompleteAircraft.actualTakeoffTime = taxiCompleteEvent.time;
        simContext.state.aircraft(idxTaxiCompleteAircraft) = taxiCompleteAircraft;
    end
end