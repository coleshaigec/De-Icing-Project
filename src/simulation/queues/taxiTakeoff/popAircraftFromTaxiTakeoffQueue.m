function [aircraftID, taxiTakeoffQueue] = popAircraftFromTaxiTakeoffQueue(taxiTakeoffQueue)
% POPAIRCRAFTFROMTAXITAKEOFFQUEUE Removes and returns first aircraft in queue

    assert(~isempty(taxiTakeoffQueue), ...
        'popAircraftFromTaxiTakeoffQueue:EmptyQueue', ...
        'Cannot pop from an empty taxi/takeoff queue.');

    aircraftID = taxiTakeoffQueue(1);

    assert(isscalar(aircraftID) && aircraftID > 0 && isfinite(aircraftID), ...
        'popAircraftFromTaxiTakeoffQueue:InvalidAircraftID', ...
        'Invalid aircraftID popped from taxi/takeoff queue: %g.', aircraftID);

    taxiTakeoffQueue = taxiTakeoffQueue(2:end);
end