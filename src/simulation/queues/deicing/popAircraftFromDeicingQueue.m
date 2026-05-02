function [aircraftID, deicingQueue] = popAircraftFromDeicingQueue(deicingQueue)
    if isempty(deicingQueue)
        error('popAircraftFromDeicingQueue:EmptyQueue', ...
            'Cannot pop from an empty deicing queue.');
    end

    aircraftID = deicingQueue(1);
    deicingQueue = deicingQueue(2:end);
end