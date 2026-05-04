function taxiTakeoffQueue = pushAircraftToTaxiTakeoffQueue(taxiTakeoffQueue, aircraftID)
% PUSHAIRCRAFTTOTAXITAKEOFFQUEUE Adds aircraft ID to taxi/takeoff queue (FIFO)
    assert(isscalar(aircraftID) && aircraftID > 0 && isfinite(aircraftID), ...
        'Invalid aircraftID pushed to taxi queue: %g', aircraftID);
    taxiTakeoffQueue(end + 1, 1) = aircraftID;

    assert(isempty(taxiTakeoffQueue) || all(taxiTakeoffQueue > 0 & isfinite(taxiTakeoffQueue)), ...
    'Input taxiTakeoffQueue already contains invalid IDs.');
end