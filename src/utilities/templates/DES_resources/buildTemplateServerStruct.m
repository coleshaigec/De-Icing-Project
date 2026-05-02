function templateServerStruct = buildTemplateServerStruct()
    % BUILDTEMPLATESERVERSTRUCT Builds template deicing server resource representation struct.
    %
    % OUTPUT
    %  templateServerStruct struct with fields
    %      .id
    %      .isBusy
    %      .currentServiceStartTime
    %      .currentAircraftId

    templateServerStruct = struct();
    templateServerStruct.id = NaN;
    templateServerStruct.isBusy = false;
    templateServerStruct.currentServiceStartTime = NaN;
    templateServerStruct.currentAircraftId = NaN;
end