function simContext = handleAircraftArrival(simContext, arrivalEvent)
    % HANDLEAIRCRAFTARRIVAL Handles aircraft arrival event
    %
    % INPUTS
    %  simContext struct with fields
    %
    %  arrivalEvent struct with fields 
    %
    % OUTPUT
    %  simContext struct with fields

    % -- Construct aircraft and push to state --
    newAircraft = constructAircraft(arrivalEvent, simContext);
    simContext.state = pushAircraftToState(simContext.state, newAircraft);

    % -- Check for empty de-icing servers and decide where to send the aircraft --
    idleIdx = find(~[simContext.state.deicingServers.isBusy], 1, 'first');
    if ~isempty(idleIdx)
        % If a server is available, schedule a deicing job
        simContext = scheduleDeicingJob(simContext, newAircraft.id, arrivalEvent.time, idleIdx);
    else 
        % If no empty servers, send aircraft to deicing queue
        simContext.state.deicingQueue = pushAircraftToDeicingQueue(simContext.state.deicingQueue, newAircraft.id);
    end
end