function aircraftTypeInfo = getAircraftTypeInfo()
    % GETAIRCRAFTTYPEINFO Returns the aircraft types used in simulation and their occurrence probabilities.
    %
    % OUTPUT
    %  aircraftTypes struct with fields
    %      .names (string array)
    %      .probabilities (array of doubles) - must sum to one
    %
    % NOTES
    % - Four aircraft types are used here to represent a heterogeneity of
    % de-icing service structures
    % - The Embraer E175 is used as a representative small regional aircraft. These
    % and similar types are very common at large hub airports.
    % - The Airbus A320 is used as a representative short/medium range, moderately
    % sized aircraft. These are among the most common aircraft in passenger
    % service today. 
    % - The Boeing 757 is used as a representative medium-range, upper
    % mid-size aircraft. These and similar aircraft like the A321 are
    % commonly found at major hubs around the world.
    % - The Airbus A350 is used as a representative wide-body/long-haul
    % aircraft. These are the least frequently occurring class of aircraft,
    % as large aircraft like this make up a small share of aircraft
    % movements at most hubs.

    aircraftTypeNames = ["E175", "A320", "B757", "A350"];
    aircraftTypeProbabilities = [0.4, 0.3, 0.2, 0.1];

    aircraftTypeInfo = struct();
    aircraftTypeInfo.names = aircraftTypeNames;
    aircraftTypeInfo.probabilities = aircraftTypeProbabilities;
end