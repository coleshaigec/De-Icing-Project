function annualResults = aggregateDayLevelSimulationResults(dayLevelResults, simulationPlan)
    % AGGREGATEDAYLEVELSIMULATIONRESULTS Aggregates paired DES and analytic day-level results.
    %
    % INPUT
    %  dayLevelResults struct array
    %      Each element must contain:
    %          .DES
    %          .analyticModel
    %
    %  simulationPlan struct
    %
    % OUTPUT
    %  annualResults struct with fields
    %      .DES
    %      .analyticModel
    %      .simulationPlan

    arguments
        dayLevelResults (:, 1) struct
        simulationPlan (1, 1) struct
    end

    if isempty(dayLevelResults)
        annualResults = struct();
        annualResults.DES = buildTemplateSimulationResultStruct();
        annualResults.analyticModel = buildTemplateSimulationResultStruct();
        annualResults.simulationPlan = simulationPlan;
        return;
    end

    numDays = numel(dayLevelResults);

    templateDESDayResult = dayLevelResults(1).DES;
    templateAnalyticDayResult = dayLevelResults(1).analyticModel;

    DESDayResults = repmat(templateDESDayResult, numDays, 1);
    analyticDayResults = repmat(templateAnalyticDayResult, numDays, 1);

    for idxDay = 1:numDays
        DESDayResults(idxDay) = dayLevelResults(idxDay).DES;
        analyticDayResults(idxDay) = dayLevelResults(idxDay).analyticModel;
    end

    annualResults = struct();
    annualResults.DES = aggregateSingleModelDayLevelSimulationResults( ...
        DESDayResults, simulationPlan);

    annualResults.analyticModel = aggregateSingleModelDayLevelSimulationResults( ...
        analyticDayResults, simulationPlan);

    annualResults.simulationPlan = simulationPlan;
end