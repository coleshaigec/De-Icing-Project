function simContext = handleDeicingComplete(simContext, deicingCompleteEvent)
    % HANDLEDEICINGCOMPLETE Handles deicing completion event.
    
    % ===============================
    % Deicing subsystem state updates
    % ===============================
    serverID = deicingCompleteEvent.serverID;
    if ~isDeicingQueueEmpty(simContext.state.deicingQueue)
        [nextDeicingAircraftID, updatedDeicingQueue] = popAircraftFromDeicingQueue();
        simContext.state.deicingQueue = updatedDeicingQueue;
        simContext = scheduleDeicingJob(simContext, nextDeicingAircraftID, deicingCompleteEvent.time, serverID);
    else
        simContext.state.deicingServers(serverID).isBusy = false;
    end

    % =======================
    % Aircraft state updates
    % =======================
    
    % Steps here:
    % 1. Have to go implement taxi/takeoff queue



    % -- Update state for aircraft --
    % Will need the below in a moment
    % templateAircraftStruct.currentDeicingServiceCompletionTime = NaN;

end