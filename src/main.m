function main()
    clc; clearvars; rng('default');
    % MAIN Runs full pipeline workflow, building and executing experiment plan.
    plans = unpackSimulationParameterGrids();

    simulationResults = runAllSimulations(plans);

        S = simulationResults(2);
    fields = fieldnames(S);

% Loop through fields and print values
for i = 1:length(fields)
    fieldName = fields{i};
    value = S.(fieldName); % Dynamic field referencing
    fprintf('%s: ', fieldName);
    disp(value);
end
    writeSimulationResultsToCSV(simulationResults);
    % resultsWithCAPEX = runCAPEXSweepsAndAddToSimulationResults();

    fprintf('CSV write complete.\n');
end