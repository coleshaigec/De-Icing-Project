function arrivalEvents = buildAircraftArrivalEventsFromTimestamps(arrivalTimestamps)
    % BUILDAIRCRAFTARRIVALEVENTSFROMTIMESTAMPS Maps aircraft arrival timestamp samples into event structs usable by the simulator.
    %
    % INPUT
    %  arrivalTimestamps (numArrivals x 1 double)
    %
    % OUTPUT
    %  arrivalEvents array of event structs

    % -- Compute number of arrivals and preallocate output array --
    numArrivals = numel(arrivalTimestamps);

    templateEventStruct = buildTemplateEventStruct();
    arrivalEvents = repmat(templateEventStruct, numArrivals, 1);

    for i = 1 : numArrivals
        arrivalEvents(i).time = arrivalTimestamps(i);
        arrivalEvents(i).type = "aircraftArrival";
        arrivalEvents(i).aircraftID = i;
    end
end