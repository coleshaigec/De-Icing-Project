function templateStateStruct = buildTemplateStateStruct()
    % BUILDTEMPLATESTATESTRUCT Builds template struct for global DES state tracking.
    %
    % OUTPUT
    %  templateStateStruct struct with fields
    %      .t (system clock)
    %      .aircraft (array of aircraft structs)
    %      .deicingQueue (array of aircraft IDs)
    %      .taxiTakeoffSubsystem (array of aircraft IDs)
    %      .deicingServers (array of server structs)
    %      .nextAircraftID (positive integer)

    templateStateStruct = struct();
    templateStateStruct.t = NaN;
    templateStateStruct.aircraft = buildTemplateAircraftStruct();
    templateStateStruct.deicingQueue = [];
    templateStateStruct.taxiTakeoffSubsystem = [];
    templateStateStruct.deicingServers = [];
    templateStateStruct.nextAircraftID = 1;
end