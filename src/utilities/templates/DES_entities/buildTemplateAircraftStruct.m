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
    %      .currentLocation ("deicing", "taxi", "departed", or "returningToDeicing")

    templateAircraftStruct = struct();
    templateAircraftStruct.id = NaN;
    templateAircraftStruct.type = "";
    templateAircraftStruct.initialArrivalTime = NaN;
    templateAircraftStruct.deicingServiceTimeMeanMultiplier = NaN;
    templateAircraftStruct.deicingServiceTimeCVMultiplier = NaN;
    templateAircraftStruct.currentDeicingQueueEntryTime = NaN;
    templateAircraftStruct.currentDeicingServiceStartTime = NaN;
    templateAircraftStruct.currentDeicingServiceCompletionTime = NaN;
    templateAircraftStruct.currentTaxiTakeoffStartTime = NaN;
    templateAircraftStruct.hotLimit = NaN;
    templateAircraftStruct.numHOTViolations = NaN;
    templateAircraftStruct.numDeicingCyclesCompleted = NaN;
    templateAircraftStruct.totalDeicingQueueingDelay = NaN;
    templateAircraftStruct.totalDeicingServiceTime = NaN;
    templateAircraftStruct.totalTaxiTakeoffQueueingDelay = NaN;
    templateAircraftStruct.totalTaxiTakeoffServiceTime = NaN;
    templateAircraftStruct.isCancelled = false;
    templateAircraftStruct.STD = NaN;
    templateAircraftStruct.actualTakeoffTime = NaN;
    templateAircraftStruct.cancellationTime = NaN;
    templateAircraftStruct.currentLocation = "";
end