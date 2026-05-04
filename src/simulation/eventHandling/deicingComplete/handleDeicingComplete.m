function simContext = handleDeicingComplete(simContext, deicingCompleteEvent)
    % HANDLEDEICINGCOMPLETE Handles deicing completion event.

    assert(deicingCompleteEvent.aircraftID > 0 && isfinite(deicingCompleteEvent.aircraftID), ...
    "Invalid deicingCompleteEvent.aircraftID: %g", deicingCompleteEvent.aircraftID);

    serverID = deicingCompleteEvent.serverID;
    completedAircraftID = deicingCompleteEvent.aircraftID;

    assert(completedAircraftID > 0 && isfinite(completedAircraftID), ...
        "Invalid deicingCompleteEvent.aircraftID.");

    % -- First update completed aircraft state --
    [idxAircraft, ~] = findAircraftById(simContext.state, completedAircraftID);

    simContext.state.aircraft(idxAircraft).currentDeicingServiceCompletionTime = deicingCompleteEvent.time;
    simContext.state.aircraft(idxAircraft).numDeicingCyclesCompleted = ...
        simContext.state.aircraft(idxAircraft).numDeicingCyclesCompleted + 1;
    simContext.state.aircraft(idxAircraft).currentLocation = "taxi";
   

    % -- Move completed aircraft into taxi/takeoff subsystem --
    idleIdx = find(~[simContext.state.taxiTakeoffServers.isBusy], 1, 'first');

    if ~isempty(idleIdx)
        simContext = scheduleTaxiTakeoffJob( ...
            simContext, completedAircraftID, deicingCompleteEvent.time, idleIdx);
    else
        simContext.state.taxiTakeoffQueue = pushAircraftToTaxiTakeoffQueue( ...
            simContext.state.taxiTakeoffQueue, completedAircraftID);
    end

    % -- Then advance deicing server to next queued aircraft, if any --
    if ~isDeicingQueueEmpty(simContext.state.deicingQueue)
        [nextDeicingAircraftID, updatedDeicingQueue] = ...
            popAircraftFromDeicingQueue(simContext.state.deicingQueue);

        [idxNextAircraft, ~] = findAircraftById(simContext.state, nextDeicingAircraftID);
        simContext.state.aircraft(idxNextAircraft).totalDeicingQueueingDelay = ...
            simContext.state.aircraft(idxNextAircraft).totalDeicingQueueingDelay + ...
            deicingCompleteEvent.time - ...
            simContext.state.aircraft(idxNextAircraft).currentDeicingQueueEntryTime;

        simContext.state.deicingQueue = updatedDeicingQueue;

        simContext = scheduleDeicingJob( ...
            simContext, nextDeicingAircraftID, deicingCompleteEvent.time, serverID);
    else
        simContext.state.deicingServers(serverID).isBusy = false;
        simContext.state.deicingServers(serverID).currentAircraftId = NaN;
        simContext.state.deicingServers(serverID).currentServiceStartTime = NaN;
    end
end