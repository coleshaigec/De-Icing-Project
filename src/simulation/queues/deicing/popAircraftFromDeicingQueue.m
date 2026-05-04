function [aircraftID, deicingQueue] = popAircraftFromDeicingQueue(deicingQueue)

    assert(~isempty(deicingQueue), ...
        'popAircraftFromDeicingQueue:EmptyQueue', ...
        'Cannot pop from empty deicing queue.');

    aircraftID = deicingQueue(1);

    assert(isscalar(aircraftID) && aircraftID > 0 && isfinite(aircraftID), ...
        'popAircraftFromDeicingQueue:InvalidAircraftID', ...
        'Invalid aircraftID popped from deicing queue: %g.', aircraftID);

    deicingQueue = deicingQueue(2:end);
end