function deicingQueue = pushAircraftToDeicingQueue(deicingQueue, aircraftID)

    assert(isscalar(aircraftID) && aircraftID > 0 && isfinite(aircraftID), ...
        'pushAircraftToDeicingQueue:InvalidAircraftID', ...
        'Invalid aircraftID pushed to deicing queue: %g.', aircraftID);
    
    assert(isempty(deicingQueue) || all(deicingQueue > 0 & isfinite(deicingQueue)), ...
    'Input deicingQueue already contains invalid IDs.');


    deicingQueue(end + 1, 1) = aircraftID;
end