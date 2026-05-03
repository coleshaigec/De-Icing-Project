function [aircraftID, taxiTakeoffQueue] = popAircraftFromTaxiTakeoffQueue(taxiTakeoffQueue)
% POPAIRCRAFTFROMTAXITAKEOFFQUEUE Removes and returns first aircraft in queue

    if isempty(taxiTakeoffQueue)
        error('popAircraftFromTaxiTakeoffQueue:EmptyQueue', ...
            'Cannot pop from an empty taxi/takeoff queue.');
    end

    aircraftID = taxiTakeoffQueue(1);
    taxiTakeoffQueue = taxiTakeoffQueue(2:end);
end