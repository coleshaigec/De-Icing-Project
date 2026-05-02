function deicingQueue = pushAircraftToDeicingQueue(deicingQueue, aircraftID)
    deicingQueue(end + 1, 1) = aircraftID;
end