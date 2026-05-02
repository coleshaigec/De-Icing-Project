function templateEventStruct = buildTemplateEventStruct()
    % BUILDTEMPLATEEVENTSTRUCT Builds template event struct for use in discrete-event simulation.
    %
    % OUTPUT
    %  templateEventStruct struct with fields
    %      .time
    %      .type
    %      .aircraftID
    %      .serverID

    templateEventStruct = struct();
    templateEventStruct.time = NaN;
    templateEventStruct.type = "";
    templateEventStruct.aircraftID = NaN;
    templateEventStruct.serverID = NaN;
end