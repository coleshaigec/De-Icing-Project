function templateStormEventStruct = buildTemplateStormEventStruct()
    % BUILDTEMPLATESTORMEVENTSTRUCT Builds template storm event struct for preallocation.
    %
    % OUTPUT
    %  templateStormEventStruct struct with fields
    %      .eventIndex (positive integer)             - index of storm event within the annual scenario
    %      .severity (nonnegative double)             - sampled latent storm severity
    %      .durationHours (positive double)           - storm duration in hours
    %      .fluidCostMultiple (positive double)       - storm-specific fluid cost multiplier
    %      .activationCostMultiple (positive double)  - storm-specific activation cost multiplier

    templateStormEventStruct = struct();
    templateStormEventStruct.eventIndex = [];
    templateStormEventStruct.severity = [];
    templateStormEventStruct.durationHours = [];
    templateStormEventStruct.fluidCostMultiple = [];
    templateStormEventStruct.activationCostMultiple = [];
end