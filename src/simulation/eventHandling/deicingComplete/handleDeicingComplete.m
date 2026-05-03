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
    % PSEUDOCODE FIRST
    % IF any server empty
    %    scheduleTaxiComplete
    % ELSE 
    %    pushToTTQueue

    
    
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



    % -- Update state for aircraft --
    % Will need the below in a moment
    % templateAircraftStruct.currentDeicingServiceCompletionTime = NaN;

end