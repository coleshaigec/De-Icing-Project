function simContext = handleAircraftArrival(simContext, arrivalEvent)
    % HANDLEAIRCRAFTARRIVAL Handles aircraft arrival event
    %
    % INPUTS
    %  simContext struct with fields
    %
    %  arrivalEvent struct with fields 
    %
    % OUTPUT
    %  simContext struct with fields

    % -- Construct aircraft --
    newAircraft = constructAircraft(arrivalEvent);

    % -- Check de-icing state and update accordingly --
    

end