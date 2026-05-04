function simContext = handleEvent(simContext, currentEvent)
    simContext = sanitizeSimQueues(simContext);
    switch currentEvent.type
        case "aircraftArrival"
            simContext = handleAircraftArrival(simContext, currentEvent);

        case "deicingComplete"
            simContext = handleDeicingComplete(simContext, currentEvent);

        case "taxiComplete"
            simContext = handleTaxiComplete(simContext, currentEvent);

        case "hotViolatorArrival"
            simContext = handleHOTViolatorArrival(simContext, currentEvent);
            
        otherwise
            error('handleEvent:UnknownEventType', ...
                'Unknown event type: %s', currentEvent.type);
    end
    simContext = sanitizeSimQueues(simContext);
%     badMask = ~(simContext.state.taxiTakeoffQueue > 0) | ...
%           ~isfinite(simContext.state.taxiTakeoffQueue);
% 
% if any(badMask)
%     disp(currentEvent)
%     disp(simContext.state.taxiTakeoffQueue)
%     error('handleEvent:InvalidTaxiQueue', ...
%         'Invalid taxi queue after handling event type %s for aircraftID %g.', ...
%         currentEvent.type, currentEvent.aircraftID);
% end
    
    % Print event-handling logic to test DES
    % printDESDebugState(simContext, currentEvent);
    
end


function printDESDebugState(simContext, currentEvent)
    % PRINTDESDEBUGSTATE Prints detailed DES state after handling one event.

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('DES DEBUG TRACE\n');
    fprintf('============================================================\n');

    fprintf('Clock: %.6f\n', simContext.clock);
    fprintf('Handled event:\n');
    fprintf('  time       : %.6f\n', currentEvent.time);
    fprintf('  type       : %s\n', string(currentEvent.type));
    fprintf('  aircraftID : %g\n', currentEvent.aircraftID);
    fprintf('  serverID   : %g\n', currentEvent.serverID);

    fprintf('\n--- Queues ---\n');
    fprintf('Deicing queue length      : %d\n', numel(simContext.state.deicingQueue));
    fprintf('Deicing queue aircraft IDs: ');
    disp(simContext.state.deicingQueue);

    fprintf('Taxi/takeoff queue length      : %d\n', numel(simContext.state.taxiTakeoffQueue));
    fprintf('Taxi/takeoff queue aircraft IDs: ');
    disp(simContext.state.taxiTakeoffQueue);

    fprintf('\n--- Deicing servers ---\n');
    printServerArray(simContext.state.deicingServers);

    fprintf('\n--- Taxi/takeoff servers ---\n');
    printServerArray(simContext.state.taxiTakeoffServers);

    fprintf('\n--- Event calendar ---\n');
    printEventCalendar(simContext.eventCalendar);

    fprintf('\n--- Aircraft state tracker ---\n');
    printAircraftArray(simContext.state.aircraft);

    fprintf('============================================================\n\n');
end

function printServerArray(serverArray)
    % PRINTSERVERARRAY Prints server resource states.

    if isempty(serverArray)
        fprintf('  <empty server array>\n');
        return;
    end

    fprintf('  idx | id | busy | currentAircraftId | currentServiceStartTime\n');
    fprintf('  ----|----|------|-------------------|------------------------\n');

    for idxServer = 1:numel(serverArray)
        server = serverArray(idxServer);

        fprintf('  %3d | %2g | %4d | %17g | %22.6f\n', ...
            idxServer, ...
            server.id, ...
            server.isBusy, ...
            server.currentAircraftId, ...
            server.currentServiceStartTime);
    end
end

function printEventCalendar(eventCalendar)
    events = eventCalendar.events;

    if isempty(events)
        fprintf('  <empty>\n');
        return;
    end

    fprintf('  idx | time       | type               | aircraftID | serverID\n');
    fprintf('  ----|------------|--------------------|------------|---------\n');

    maxEventsToPrint = min(numel(events), 5);
    for iEvent = 1:maxEventsToPrint
        event = events(iEvent);

        fprintf('  %3d | %10.6f | %-18s | %10g | %7g\n', ...
            iEvent, ...
            event.time, ...
            string(event.type), ...
            event.aircraftID, ...
            event.serverID);
    end
end

function printAircraftArray(aircraftArray)
    % PRINTAIRCRAFTARRAY Prints tracked aircraft states.

    if isempty(aircraftArray)
        fprintf('  <empty aircraft array>\n');
        return;
    end

    fprintf(['  idx | id | type | loc                | arr     | DI_q_in | ', ...
             'DI_start | DI_done | TT_start | HOT     | cycles | ', ...
             'DI_q_tot | DI_svc_tot | TT_q_tot | TT_svc_tot | STD     | takeoff\n']);
    fprintf(['  ----|----|------|--------------------|---------|---------|', ...
             '----------|---------|----------|---------|--------|', ...
             '----------|------------|----------|------------|---------|--------\n']);

    for idxAircraft = 1:numel(aircraftArray)
        aircraft = aircraftArray(idxAircraft);

        fprintf(['  %3d | %2g | %-4s | %-18s | %7.3f | %7.3f | ', ...
                 '%8.3f | %7.3f | %8.3f | %7.3f | %6g | ', ...
                 '%8.3f | %10.3f | %8.3f | %10.3f | %7.3f | %7.3f\n'], ...
            idxAircraft, ...
            aircraft.id, ...
            string(aircraft.type), ...
            string(aircraft.currentLocation), ...
            aircraft.initialArrivalTime, ...
            aircraft.currentDeicingQueueEntryTime, ...
            aircraft.currentDeicingServiceStartTime, ...
            aircraft.currentDeicingServiceCompletionTime, ...
            aircraft.currentTaxiTakeoffStartTime, ...
            aircraft.hotLimit, ...
            aircraft.numDeicingCyclesCompleted, ...
            aircraft.totalDeicingQueueingDelay, ...
            aircraft.totalDeicingServiceTime, ...
            aircraft.totalTaxiTakeoffQueueingDelay, ...
            aircraft.totalTaxiTakeoffServiceTime, ...
            aircraft.STD, ...
            aircraft.actualTakeoffTime);
    end
end