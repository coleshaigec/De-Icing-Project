function allSimulationResults = runAllSimulations(simulationPlans)
    % RUNALLSIMULATIONS Executes all planned simulations.
    %
    % INPUT
    %  simulationPlans array of simulationPlan structs
    %
    % OUTPUT
    %  allSimulationResults array of simulationResult structs

    numSimulationsToRun = numel(simulationPlans);

    templateSimulationResultStruct = buildTemplateSimulationResultStruct();
    allSimulationResults = repmat(templateSimulationResultStruct, numSimulationsToRun, 1);

    for i = 1 : numSimulationsToRun
        fprintf('Commencing simulation %i of %i.\n', i, numSimulationsToRun);
        allSimulationResults(i) = runSingleYearSimulation(simulationPlans(i));
        fprintf('Simulation %i completed.\n\n', i);
        if mod(i, 200) == 0
            clc;
        end
    end
end