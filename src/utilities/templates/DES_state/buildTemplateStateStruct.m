function templateStateStruct = buildTemplateStateStruct()
    % BUILDTEMPLATESTATESTRUCT Builds template struct for global DES state tracking.
    %
    % OUTPUT
    %  templateStateStruct struct with fields
    %      .t (system clock)
    %      .deicingQueue (array of aircraft structs)
    %      .taxiTakeoffSubsystem (array of aircraft structs)
    %      .deicingServers (array of server structs)

    templateStateStruct = struct();
    templateStateStruct.t = NaN;
    templateStateStruct.deicingQueue = [];
    templateStateStruct.taxiTakeoffSubsystem = [];
    templateStateStruct.deicingServers = [];
end