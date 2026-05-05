function simContext = cancelFlight(simContext, aircraftIndex, cancellationTime)
    % CANCELFLIGHT Cancels flight that has exceeded the allowable number of HOT violations.
    simContext.state.aircraft(aircraftIndex).currentLocation = "cancelled";
    simContext.state.aircraft(aircraftIndex).isCancelled = true;
    simContext.state.aircraft(aircraftIndex).cancellationTime = cancellationTime;  
end