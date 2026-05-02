
% USE BELOW CODE FOR TYPE ASSIGNMENT
% -- For each arrival timestamp, assign an aircraft type and add event info --
    aircraftTypeInfo = getAircraftTypeInfo();
    probabilityThresholds = cumsum(aircraftTypeInfo.probabilities);

    for i = 1 : numArrivals
        arrivalEvents(i).time = arrivalTimestamps(i);
        % Pick aircraft type by random sampling
        typeSample = rand(1);
        if isbetween(typeSample, 0, probabilityThresholds(1))
            idxType = 1;
        elseif isbetween(typeSample, probabilityThresholds(1), probabilityThresholds(2))
            idxType = 2;
        elseif isbetween(typeSample, probabilityThresholds(2), probabilityThresholds(3))
            idxType = 3;
        else
            idxType = 4;
        end
        arrivalEvents(i).type = aircraftTypeInfo.names(idxType);

        arrivalEvents(i).aircraftID = i;
    end