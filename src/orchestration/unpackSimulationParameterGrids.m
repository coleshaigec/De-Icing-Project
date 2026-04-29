function simulationPlans = unpackSimulationParameterGrids()
    % UNPACKSIMULATIONPARAMETERGRIDS Unpacks simulation parameter grids into atomic run plans executable by the simulation pipeline. 
    %
    % OUTPUT
    %  simulationPlans array of structs, each with fields
    %      .policy struct with fields
    %          .k (positive integer)                   - number of de-icing pads
    %          .e (integer in [1,3])                   - chosen service process scenario
    %      .arrivalProcess struct                     - chosen arrival process scenario
    %      .serviceProcess struct                     - chosen service process scenario
    %      .taxiTakeoffProcess struct                 - chosen taxi/takeoff process scenario
    %      .weatherProcesses array of structs         - weather process scenario bundle
    %      .costModel struct                          - chosen cost scenario

    simulationParameterGrids = buildSimulationParameterGridsForAnalyticModel();

    kValues = simulationParameterGrids.policies.kValues;
    eValues = simulationParameterGrids.policies.eValues;

    arrivalProcesses = simulationParameterGrids.arrivalProcesses;
    serviceProcesses = simulationParameterGrids.serviceProcesses;
    taxiTakeoffProcesses = simulationParameterGrids.taxiTakeoffProcesses;
    weatherProcesses = simulationParameterGrids.weatherProcesses;
    costModels = simulationParameterGrids.costModels;

    numKValues = numel(kValues);
    numEValues = numel(eValues);
    numArrivalProcesses = numel(arrivalProcesses);
    numTaxiTakeoffProcesses = numel(taxiTakeoffProcesses);
    numCostModels = numel(costModels);

    numSimulationPlans = numKValues ...
        * numEValues ...
        * numArrivalProcesses ...
        * numTaxiTakeoffProcesses ...
        * numCostModels;

    templateSimulationPlanStruct = buildTemplateSimulationPlanStruct();
    simulationPlans = repmat(templateSimulationPlanStruct, numSimulationPlans, 1);

    planIndex = 0;

    for iK = 1:numKValues
        for iE = 1:numEValues
            e = eValues(iE);

            assert(e >= 1 && e <= numel(serviceProcesses), ...
                'Policy service-process index e must index serviceProcesses.');

            for iArrivalProcess = 1:numArrivalProcesses
                for iTaxiTakeoffProcess = 1:numTaxiTakeoffProcesses
                    for iCostModel = 1:numCostModels
                        planIndex = planIndex + 1;

                        simulationPlans(planIndex) = templateSimulationPlanStruct;

                        simulationPlans(planIndex).policy.k = kValues(iK);
                        simulationPlans(planIndex).policy.e = e;

                        simulationPlans(planIndex).arrivalProcess = ...
                            arrivalProcesses(iArrivalProcess);

                        simulationPlans(planIndex).serviceProcess = ...
                            serviceProcesses(e);

                        simulationPlans(planIndex).taxiTakeoffProcess = ...
                            taxiTakeoffProcesses(iTaxiTakeoffProcess);

                        simulationPlans(planIndex).weatherProcesses = weatherProcesses;

                        simulationPlans(planIndex).costModel = ...
                            costModels(iCostModel);
                    end
                end
            end
        end
    end

    assert(planIndex == numSimulationPlans, ...
        'Number of generated simulation plans does not match preallocated size.');
end