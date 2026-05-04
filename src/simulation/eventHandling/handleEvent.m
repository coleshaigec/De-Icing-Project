function simContext = handleEvent(simContext, currentEvent)
    switch currentEvent.eventType
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
                'Unknown event type: %s', currentEvent.eventType);
    end
    
    % Do we need to update clock in here too?
end