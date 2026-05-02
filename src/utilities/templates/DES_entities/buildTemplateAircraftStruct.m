function templateAircraftStruct = buildTemplateAircraftStruct()
    % BUILDTEMPLATEAIRCRAFTSTRUCT Builds template struct for an aircraft entity.
    %
    % OUTPUT
    %  templateAircraftStruct struct with fields
    %      .id
    %      .type
    %      .initialArrivalTime
    %      .currentDeicingQueueEntryTime
    %      .currentDeicingServiceStartTime
    %      .currentDeicingServiceCompletionTime
    %      .hotLimit
    %      .numDeicingCyclesCompleted
    %      .STD
    %      .takeoffTime
    %      .currentLocation ("deicing", "taxi", or "departed")

    templateAircraftStruct = struct();
    templateAircraftStruct.id = NaN;
    templateAircraftStruct.type = "";
    templateAircraftStruct.initialArrivalTime = NaN;
    templateAircraftStruct.currentDeicingQueueEntryTime = NaN;
    templateAircraftStruct.currentDeicingServiceStartTime = NaN;
    templateAircraftStruct.currentDeicingServiceCompletionTime = NaN;
    templateAircraftStruct.hotLimit = NaN;
    templateAircraftStruct.numDeicingCyclesCompleted = NaN;
    templateAircraftStruct.STD = NaN;
    templateAircraftStruct.actualTakeoffTime = NaN;
    templateAircraftStruct.currentLocation = "";
end