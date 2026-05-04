function simContext = handleDeicingComplete(simContext, deicingCompleteEvent)
    % HANDLEDEICINGCOMPLETE Handles deicing completion event.
    
    % ===============================
    % Deicing subsystem state updates
    % ===============================
    serverID = deicingCompleteEvent.serverID;
    if ~isDeicingQueueEmpty(simContext.state.deicingQueue)
        [nextDeicingAircraftID, updatedDeicingQueue] = popAircraftFromDeicingQueue();
        simContext.state.deicingQueue = updatedDeicingQueue;
        simContext = scheduleDeicingJob(simContext, nextDeicingAircraftID, deicingCompleteEvent.time, serverID, simContext.serviceProcess);
    else
        simContext.state.deicingServers(serverID).isBusy = false;
    end

    % =======================
    % Aircraft state updates
    % =======================  
    
    % Steps here:
    % 1. Check if there are any empty taxi/takeoff servers
    % 2. If YES to above:
    %      - Assign aircraft to the server and schedule the completion event
    %      - What are Gamma parameters for this?
    %    If NO to above:
    %      - Put the aircraft in the queue
    %    
    % 3. Schedule completion event -- G/G/k structure matters here!
    % Put the gamma sampling INSIDE the scheduling module
    %
    % Aircraft state updates:
    % - Change location

    % -- Check for empty taxi/takeoff servers and decide where to send the aircraft --
    idleIdx = find(~[simContext.state.taxiTakeoffServers.isBusy], 1, 'first');
    if ~isempty(idleIdx)
        % If a server is available, schedule a taxi/takeoff job
        simContext = scheduleTaxiTakeoffJob(simContext, deicingCompleteEvent.aircraftID, deicingCompleteEvent.time, idleIdx);
    else 
        % If no empty servers, send aircraft to taxi/takeoff queue
        simContext.state.taxiTakeoffQueue = pushAircraftToTaxiTakeoffQueue(simContext.state.taxiTakeoffQueue, deicingCompleteEvent.aircraftID);
    end

    % -- Update aircraft state --
    [idxAircraft, ~] = findAircraftById(simContext.state, deicingCompleteEvent.aircraftID);
    simContext.state.aircraft(idxAircraft).currentDeicingServiceCompletionTime = deicingCompleteEvent.time;
    simContext.state.aircraft(idxAircraft).numDeicingCyclesCompleted = simContext.state.aircraft(idxAircraft).numDeicingCyclesCompleted + 1;
    simContext.state.aircraft(idxAircraft).currentLocation = "taxi";
end