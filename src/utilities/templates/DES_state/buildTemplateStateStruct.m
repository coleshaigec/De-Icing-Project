function templateStateStruct = buildTemplateStateStruct()
    % BUILDTEMPLATESTATESTRUCT Builds template struct for global DES state tracking.
    %
    % OUTPUT
    %  templateStateStruct struct with fields
    %      .aircraft (array of aircraft structs)
    %      .deicingQueue (array of aircraft IDs)
    %      .taxiTakeoffSubsystem (array of aircraft IDs)
    %      .deicingServers (array of server structs)
    %      .taxiTakeoffServers (array of server structs)

    templateStateStruct = struct();
    templateStateStruct.aircraft = buildTemplateAircraftStruct();
    templateStateStruct.deicingQueue = [];
    templateStateStruct.taxiTakeoffQueue = [];
    templateStateStruct.taxiTakeoffServers = [];
    templateStateStruct.deicingServers = [];
end