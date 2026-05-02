function simulationPlans = unpackSimulationParameterGrids()
    % UNPACKSIMULATIONPARAMETERGRIDS Unpacks simulation parameter grids into annual simulation plans executable by the simulation pipeline.
    %
    % OUTPUT
    %  simulationPlans array of structs, each with fields
    %      .policy struct with fields
    %          .k (positive integer)                   - number of de-icing pads
    %          .e (integer in [1,3])                   - chosen service process scenario
    %      .arrivalProcess struct                     - chosen arrival process scenario
    %      .serviceProcess struct                     - chosen service process scenario
    %      .taxiTakeoffProcess struct                 - chosen taxi/takeoff process scenario
    %      .annualNumberOfStorms (positive integer)   - number of storm-day events simulated for the year
    %      .stormDistributionParameters struct        - global parameters used to generate storm events
    %      .stormEvents array of structs              - generated day-level storm events for the annual scenario
    %      .costModel struct                          - chosen cost scenario
    %
    % NOTES
    % - Each element of simulationPlans represents one annual operating scenario.
    % - Day-level storm simulations should be executed downstream by
    %   runSingleYearSimulation, which loops over simulationPlan.stormEvents
    %   and calls runSingleSimulation for each storm event.
    % - runSingleSimulation should be interpreted as a day-level simulation
    %   utility, not as an annual simulation utility.

    simulationParameterGrids = buildSimulationParameterGridsForAnalyticModel();

    kValues = simulationParameterGrids.policies.kValues;
    eValues = simulationParameterGrids.policies.eValues;

    arrivalProcesses = simulationParameterGrids.arrivalProcesses;
    serviceProcesses = simulationParameterGrids.serviceProcesses;
    taxiTakeoffProcesses = simulationParameterGrids.taxiTakeoffProcesses;
    annualNumberOfStormsValues = simulationParameterGrids.annualNumberOfStormsValues;
    stormDistributionParameters = simulationParameterGrids.stormDistributionParameters;
    costModels = simulationParameterGrids.costModels;

    numKValues = numel(kValues);
    numEValues = numel(eValues);
    numArrivalProcesses = numel(arrivalProcesses);
    numTaxiTakeoffProcesses = numel(taxiTakeoffProcesses);
    numAnnualNumberOfStormsValues = numel(annualNumberOfStormsValues);
    numCostModels = numel(costModels);

    numSimulationPlans = numKValues ...
        * numEValues ...
        * numArrivalProcesses ...
        * numTaxiTakeoffProcesses ...
        * numAnnualNumberOfStormsValues ...
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
                    for iAnnualNumberOfStorms = 1:numAnnualNumberOfStormsValues
                        for iCostModel = 1:numCostModels
                            planIndex = planIndex + 1;

                            annualNumberOfStorms = ...
                                annualNumberOfStormsValues(iAnnualNumberOfStorms);

                            stormEvents = buildStormEvents( ...
                                annualNumberOfStorms, ...
                                stormDistributionParameters);

                            simulationPlans(planIndex) = templateSimulationPlanStruct;

                            simulationPlans(planIndex).policy.k = kValues(iK);
                            simulationPlans(planIndex).policy.e = e;

                            simulationPlans(planIndex).arrivalProcess = ...
                                arrivalProcesses(iArrivalProcess);

                            simulationPlans(planIndex).serviceProcess = ...
                                serviceProcesses(e);

                            simulationPlans(planIndex).taxiTakeoffProcess = ...
                                taxiTakeoffProcesses(iTaxiTakeoffProcess);

                            simulationPlans(planIndex).annualNumberOfStorms = ...
                                annualNumberOfStorms;

                            simulationPlans(planIndex).stormDistributionParameters = ...
                                stormDistributionParameters;

                            simulationPlans(planIndex).stormEvents = stormEvents;

                            simulationPlans(planIndex).costModel = ...
                                costModels(iCostModel);
                        end
                    end
                end
            end
        end
    end

    assert(planIndex == numSimulationPlans, ...
        'Number of generated simulation plans does not match preallocated size.');
end