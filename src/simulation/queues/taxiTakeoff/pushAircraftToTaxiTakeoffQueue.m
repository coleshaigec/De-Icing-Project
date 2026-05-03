function taxiTakeoffQueue = pushAircraftToTaxiTakeoffQueue(taxiTakeoffQueue, aircraftID)
% PUSHAIRCRAFTTOTAXITAKEOFFQUEUE Adds aircraft ID to taxi/takeoff queue (FIFO)
    taxiTakeoffQueue(end + 1, 1) = aircraftID;
end