% % % function simulationParameterGrids = buildSimulationParameterGridsForAnalyticModel()
% % %     % BUILDSIMULATIONPARAMETERGRIDS Builds parameter grids for simulation runs that use the analytic model.
% % %     %
% % %     % OUTPUT
% % %     %  simulationParameterGrids struct with fields
% % %     %      .policies struct with fields
% % %     %          .kValues (array of positive integers)   - chosen number of servers
% % %     %          .eValues (array of integers in [1,3])   - chosen service rate scenarios
% % %     %      .arrivalProcesses array of structs, each with fields
% % %     %          .scenarioName (string)                  - name of chosen arrival process scenario
% % %     %          .lambdaBase (nonnegative double)        - baseline arrival rates
% % %     %          .lambdaPeak (nonnegative double)        - peak arrival rates
% % %     %          .t0 (positive integer)                  - arrival pulse peak times
% % %     %          .sigmaLambda (nonnegative double)       - arrival pulse tapering coefficients
% % %     %          .Ca (nonnegative double)                - arrival pulse coefficients of variation
% % %     %      .serviceProcesses array of structs, each with fields
% % %     %          .scenarioName (string)                  - name of chosen service process scenario
% % %     %          .muDI (nonnegative float)               - scenario-specific de-icing service rates                   
% % %     %          .eta (nonnegative float)                - de-icing -> taxi/takeoff congestion propagation parameters
% % %     %          .Cs (nonnegative float)                 - de-icing process coefficient of variation
% % %     %          .activationCostMultiple (double)        - scenario-specific resource activation cost multiplier
% % %     %          .serviceProcessCAPEXCase (string)       - "low", "medium", or "high"
% % %     %      .taxiTakeoffProcesses array of structs, each with fields
% % %     %          .scenarioName (string)                  - name of chosen departure process scenario
% % %     %          .beta                                   - taxi/takeoff sojourn time congestion scaling parameter
% % %     %          .p                                      - taxi/takeoff sojourn time congestion explosion parameter
% % %     %          .T0                                     - baseline (zero-congestion) taxi/takeoff sojourn time (minutes)
% % %     %          .CT                                     - taxi/takeoff sojourn time coefficient of variation
% % %     %      .weatherProcesses array of structs, each with fields
% % %     %          .scenarioName (string)                  - name of weather process scenario
% % %     %          .numOccurrences (double)                - annual scenario occurrence frequency
% % %     %          .duration (double)                      - number of hours for which specified storm type persists
% % %     %          .fluidCostMultiple (string)             - scenario-specific fluid cost multiplier 
% % %     %          .activationCostMultiple (double)        - scenario-specific resource activation cost multiplier
% % %     %      .costModel array of structs, each with fields
% % %     %          .scenarioName (string)                  - name of chosen cost scenario
% % %     %          .singlePadCAPEX (nonnegative double)    - initial capital outlay to build a single pad
% % %     %          .serviceProcessCAPEXes (doubles)        - initial capital outlay for equipment and other inputs in each service process scenario
% % %     %          .delayCosts (doubles)                   - escalating piecewise linear delay cost terms [CD1, CD2, CD3]
% % %     %          .baseFluidCost (double)                 - base fluid cost
% % %     %          .baseActivationCost (double)            - base resource activation cost
% % %     %      
% % %     % NOTES
% % %     % - This file is a global configuration utility that allows the user to
% % %     % adjust simulation parameters as they desire. Changing the values
% % %     % hard-coded in this file enables exploration of different policies and
% % %     % sensitivities of results to key system parameters.
% % %     % - Fluid costs are treated as weather-specific parameters and are thus 
% % %     % assumed to be independent of the chosen service process scenario. 
% % %     % - Delay costs capture geographically dispersed network externalities and are 
% % %     % thus assumed to be independent of the chosen weather scenario.
% % % 
% % %     policies = struct();
% % %     policies.kValues = 1:8;
% % %     policies.eValues = 1:3;
% % % 
% % %     % ==================================================
% % %     % Arrival process scenarios
% % %     % ==================================================
% % %     numArrivalProcessScenarios = 3;
% % %     templateArrivalProcessStruct = buildTemplateArrivalProcessStruct();
% % %     arrivalProcesses = repmat(templateArrivalProcessStruct, numArrivalProcessScenarios, 1);
% % % 
% % %     arrivalProcesses(1) = templateArrivalProcessStruct;
% % %     arrivalProcesses(1).scenarioName = "noPeak";
% % %     arrivalProcesses(1).lambdaBase = 3;
% % %     arrivalProcesses(1).lambdaPeak = 0;
% % %     arrivalProcesses(1).t0 = 1;
% % %     arrivalProcesses(1).sigmaLambda = 1;
% % %     arrivalProcesses(1).Ca = 1;
% % % 
% % %     arrivalProcesses(2) = templateArrivalProcessStruct;
% % %     arrivalProcesses(2).scenarioName = "narrowPeak";
% % %     arrivalProcesses(2).lambdaBase = 3;
% % %     arrivalProcesses(2).lambdaPeak = 6;
% % %     arrivalProcesses(2).t0 = 200;
% % %     arrivalProcesses(2).sigmaLambda = 0.2;
% % %     arrivalProcesses(2).Ca = 1;
% % % 
% % %     arrivalProcesses(3) = templateArrivalProcessStruct;
% % %     arrivalProcesses(3).scenarioName = "broadPeak";
% % %     arrivalProcesses(3).lambdaBase = 3;
% % %     arrivalProcesses(3).lambdaPeak = 6;
% % %     arrivalProcesses(3).t0 = 200;
% % %     arrivalProcesses(3).sigmaLambda = 8;
% % %     arrivalProcesses(3).Ca = 1;
% % % 
% % %     % ==================================================
% % %     % Service process scenarios
% % %     % ==================================================
% % %     numServiceProcessScenarios = 3;
% % %     templateServiceProcessStruct = buildTemplateServiceProcessStruct();
% % %     serviceProcesses = repmat(templateServiceProcessStruct, numServiceProcessScenarios, 1);
% % % 
% % %     serviceProcesses(1) = templateServiceProcessStruct;
% % %     serviceProcesses(1).scenarioName = "baseline";
% % %     serviceProcesses(1).muDI = 0.1;
% % %     serviceProcesses(1).eta = 0.1;
% % %     serviceProcesses(1).Cs = 1;
% % %     serviceProcesses(1).activationCostMultiple = 1;
% % %     serviceProcesses(1).serviceProcessCAPEXCase = "low";
% % % 
% % %     serviceProcesses(2) = templateServiceProcessStruct;
% % %     serviceProcesses(2).scenarioName = "upgraded";
% % %     serviceProcesses(2).muDI = 0.2;
% % %     serviceProcesses(2).eta = 0.1;
% % %     serviceProcesses(2).Cs = 1;
% % %     serviceProcesses(2).activationCostMultiple = 1.5;
% % %     serviceProcesses(2).serviceProcessCAPEXCase = "medium";
% % % 
% % %     serviceProcesses(3) = templateServiceProcessStruct;
% % %     serviceProcesses(3).scenarioName = "highEnd";
% % %     serviceProcesses(3).muDI = 0.4;
% % %     serviceProcesses(3).eta = 0.1;
% % %     serviceProcesses(3).Cs = 1;
% % %     serviceProcesses(3).activationCostMultiple = 3;
% % %     serviceProcesses(3).serviceProcessCAPEXCase = "high";
% % % 
% % %     % =======================================================
% % %     % Taxi/takeoff process scenarios
% % %     % =======================================================
% % %     numTaxiTakeoffProcessScenarios = 3;
% % %     templateTaxiTakeoffProcessStruct = buildTemplateTaxiTakeoffProcessStruct();
% % %     taxiTakeoffProcesses = repmat(templateTaxiTakeoffProcessStruct, numTaxiTakeoffProcessScenarios, 1);
% % % 
% % %     taxiTakeoffProcesses(1) = templateTaxiTakeoffProcessStruct;
% % %     taxiTakeoffProcesses(1).scenarioName = "baseline";
% % %     taxiTakeoffProcesses(1).beta = 0.4;
% % %     taxiTakeoffProcesses(1).p = 1;
% % %     taxiTakeoffProcesses(1).T0 = 10;
% % %     taxiTakeoffProcesses(1).CT = 3;
% % % 
% % %     taxiTakeoffProcesses(2) = templateTaxiTakeoffProcessStruct;
% % %     taxiTakeoffProcesses(2).scenarioName = "congestionSensitive";
% % %     taxiTakeoffProcesses(2).beta = 2;
% % %     taxiTakeoffProcesses(2).p = 2;
% % %     taxiTakeoffProcesses(2).T0 = 5;
% % %     taxiTakeoffProcesses(2).CT = 3;
% % % 
% % %     taxiTakeoffProcesses(3) = templateTaxiTakeoffProcessStruct;
% % %     taxiTakeoffProcesses(3).scenarioName = "largeHub";
% % %     taxiTakeoffProcesses(3).beta = 1;
% % %     taxiTakeoffProcesses(3).p = 3 / 2;
% % %     taxiTakeoffProcesses(3).T0 = 15;
% % %     taxiTakeoffProcesses(3).CT = 3;
% % % 
% % % 
% % %     % ==================================================
% % %     % Annual storm-count and storm-severity parameters
% % %     % ==================================================
% % %     % NOTES
% % %     % - Each simulation plan represents one annual operating scenario.
% % %     % - annualNumberOfStormsValues sweeps the number of storm days in the year.
% % %     % - stormDistributionParameters parameterizes the stochastic storm event
% % %     %   generator used by buildStormEvents.
% % %     % - Storm-event heterogeneity is generated inside unpackSimulationParameterGrids
% % %     %   so that each annual simulation plan receives one explicit array of
% % %     %   day-level storm events.
% % % 
% % %     annualNumberOfStormsValues = 10:5:100;
% % % 
% % %     stormDistributionParameters = struct( ...
% % %         'alpha', 2, ...
% % %         'theta', 0.5 ...
% % %     );
% % %     % =============================================
% % %     % Cost model scenarios
% % %     % =============================================
% % %     numCostScenarios = 5;
% % %     templateCostModelStruct = buildTemplateCostModelStruct();
% % %     costModels = repmat(templateCostModelStruct, numCostScenarios, 1);
% % % 
% % %     costModels(1) = templateCostModelStruct;
% % %     costModels(1).scenarioName = "baseline";
% % %     costModels(1).singlePadCAPEX = 20;
% % %     costModels(1).serviceProcessCAPEXes = [5, 10, 20];
% % %     costModels(1).delayCosts = [5, 10, 20];
% % %     costModels(1).baseFluidCost = 1;
% % %     costModels(1).baseActivationCost = 1;
% % % 
% % %     costModels(2) = templateCostModelStruct;
% % %     costModels(2).scenarioName = "externalitySensitive";
% % %     costModels(2).singlePadCAPEX = 20;
% % %     costModels(2).serviceProcessCAPEXes = [5, 10, 20];
% % %     costModels(2).delayCosts = [10, 20, 40];
% % %     costModels(2).baseFluidCost = 1;
% % %     costModels(2).baseActivationCost = 1;
% % % 
% % %     costModels(3) = templateCostModelStruct;
% % %     costModels(3).scenarioName = "tightLaborMarket";
% % %     costModels(3).singlePadCAPEX = 20;
% % %     costModels(3).serviceProcessCAPEXes = [5, 10, 20];
% % %     costModels(3).delayCosts = [5, 10, 20];
% % %     costModels(3).baseFluidCost = 1;
% % %     costModels(3).baseActivationCost = 5;
% % % 
% % %     costModels(4) = templateCostModelStruct;
% % %     costModels(4).scenarioName = "highCAPEX";
% % %     costModels(4).singlePadCAPEX = 30;
% % %     costModels(4).serviceProcessCAPEXes = [10, 15, 25];
% % %     costModels(4).delayCosts = [5, 10, 20];
% % %     costModels(4).baseFluidCost = 1;
% % %     costModels(4).baseActivationCost = 1;
% % % 
% % %     costModels(5) = templateCostModelStruct;
% % %     costModels(5).scenarioName = "highFluidCost";
% % %     costModels(5).singlePadCAPEX = 20;
% % %     costModels(5).serviceProcessCAPEXes = [5, 10, 20];
% % %     costModels(5).delayCosts = [5, 10, 20];
% % %     costModels(5).baseFluidCost = 5;
% % %     costModels(5).baseActivationCost = 1;
% % % 
% % %     % =======================
% % %     % Populate output struct
% % %     % =======================
% % %     simulationParameterGrids = struct();
% % %     simulationParameterGrids.policies = policies;
% % %     simulationParameterGrids.arrivalProcesses = arrivalProcesses;
% % %     simulationParameterGrids.serviceProcesses = serviceProcesses;
% % %     simulationParameterGrids.taxiTakeoffProcesses = taxiTakeoffProcesses;
% % %     simulationParameterGrids.annualNumberOfStormsValues = annualNumberOfStormsValues;
% % %     simulationParameterGrids.stormDistributionParameters = stormDistributionParameters;
% % %     simulationParameterGrids.costModels = costModels;
% % % end
% % 
% % 
% % 
% % 
% % 
% % function simulationParameterGrids = buildSimulationParameterGridsForDebugDES()
% %     % BUILDSIMULATIONPARAMETERGRIDSFORDEBUGDES Builds a tiny adversarial grid for DES debugging.
% %     %
% %     % PURPOSE
% %     %  Temporary debug-only parameter grid.
% %     %  Keeps the three hard-coded service process scenarios intact.
% %     %  Shrinks all other dimensions to expose DES edge cases without running
% %     %  the full production grid.
% % 
% %     % ==================================================
% %     % Policies
% %     % ==================================================
% %     policies = struct();
% % 
% %     % k = 1 forces queueing/congestion.
% %     % k = 2 tests multi-server dispatch.
% %     % k = 4 gives a light-load sanity case.
% %     policies.kValues = [1, 2, 4];
% % 
% %     % DO NOT CHANGE: codebase assumes three service process scenarios.
% %     policies.eValues = 1:3;
% % 
% %     % ==================================================
% %     % Arrival process scenarios
% %     % ==================================================
% %     numArrivalProcessScenarios = 3;
% %     templateArrivalProcessStruct = buildTemplateArrivalProcessStruct();
% %     arrivalProcesses = repmat(templateArrivalProcessStruct, numArrivalProcessScenarios, 1);
% % 
% %     % Light baseline: should produce mostly clean flow.
% %     arrivalProcesses(1) = templateArrivalProcessStruct;
% %     arrivalProcesses(1).scenarioName = "debugLightNoPeak";
% %     arrivalProcesses(1).lambdaBase = 1.5;
% %     arrivalProcesses(1).lambdaPeak = 2;
% %     arrivalProcesses(1).t0 = 30;
% %     arrivalProcesses(1).sigmaLambda = 1;
% %     arrivalProcesses(1).Ca = 1;
% % 
% %     % Congestion case: should force deicing queueing under k = 1.
% %     arrivalProcesses(2) = templateArrivalProcessStruct;
% %     arrivalProcesses(2).scenarioName = "debugNarrowPeak";
% %     arrivalProcesses(2).lambdaBase = 2;
% %     arrivalProcesses(2).lambdaPeak = 8;
% %     arrivalProcesses(2).t0 = 30;
% %     arrivalProcesses(2).sigmaLambda = 0.2;
% %     arrivalProcesses(2).Ca = 1;
% % 
% %     % Sustained stress case: should expose calendar/queue/server logic bugs.
% %     arrivalProcesses(3) = templateArrivalProcessStruct;
% %     arrivalProcesses(3).scenarioName = "debugBroadPeak";
% %     arrivalProcesses(3).lambdaBase = 3;
% %     arrivalProcesses(3).lambdaPeak = 6;
% %     arrivalProcesses(3).t0 = 30;
% %     arrivalProcesses(3).sigmaLambda = 4;
% %     arrivalProcesses(3).Ca = 1;
% % 
% %     % ==================================================
% %     % Service process scenarios
% %     % ==================================================
% %     % DO NOT SHRINK THIS SECTION.
% %     % Codebase assumes exactly three hard-coded service process scenarios.
% % 
% %     numServiceProcessScenarios = 3;
% %     templateServiceProcessStruct = buildTemplateServiceProcessStruct();
% %     serviceProcesses = repmat(templateServiceProcessStruct, numServiceProcessScenarios, 1);
% % 
% %     serviceProcesses(1) = templateServiceProcessStruct;
% %     serviceProcesses(1).scenarioName = "baseline";
% %     serviceProcesses(1).muDI = 0.1;
% %     serviceProcesses(1).eta = 0.1;
% %     serviceProcesses(1).Cs = 1;
% %     serviceProcesses(1).activationCostMultiple = 1;
% %     serviceProcesses(1).serviceProcessCAPEXCase = "low";
% % 
% %     serviceProcesses(2) = templateServiceProcessStruct;
% %     serviceProcesses(2).scenarioName = "upgraded";
% %     serviceProcesses(2).muDI = 0.2;
% %     serviceProcesses(2).eta = 0.1;
% %     serviceProcesses(2).Cs = 1;
% %     serviceProcesses(2).activationCostMultiple = 1.5;
% %     serviceProcesses(2).serviceProcessCAPEXCase = "medium";
% % 
% %     serviceProcesses(3) = templateServiceProcessStruct;
% %     serviceProcesses(3).scenarioName = "highEnd";
% %     serviceProcesses(3).muDI = 0.4;
% %     serviceProcesses(3).eta = 0.1;
% %     serviceProcesses(3).Cs = 1;
% %     serviceProcesses(3).activationCostMultiple = 3;
% %     serviceProcesses(3).serviceProcessCAPEXCase = "high";
% % 
% %     % =======================================================
% %     % Taxi/takeoff process scenarios
% %     % =======================================================
% %     numTaxiTakeoffProcessScenarios = 2;
% %     templateTaxiTakeoffProcessStruct = buildTemplateTaxiTakeoffProcessStruct();
% %     taxiTakeoffProcesses = repmat(templateTaxiTakeoffProcessStruct, numTaxiTakeoffProcessScenarios, 1);
% % 
% %     taxiTakeoffProcesses(1) = templateTaxiTakeoffProcessStruct;
% %     taxiTakeoffProcesses(1).scenarioName = "debugBaselineTaxi";
% %     taxiTakeoffProcesses(1).beta = 0.4;
% %     taxiTakeoffProcesses(1).p = 1;
% %     taxiTakeoffProcesses(1).T0 = 10;
% %     taxiTakeoffProcesses(1).CT = 3;
% % 
% %     taxiTakeoffProcesses(2) = templateTaxiTakeoffProcessStruct;
% %     taxiTakeoffProcesses(2).scenarioName = "debugCongestedTaxi";
% %     taxiTakeoffProcesses(2).beta = 2;
% %     taxiTakeoffProcesses(2).p = 2;
% %     taxiTakeoffProcesses(2).T0 = 5;
% %     taxiTakeoffProcesses(2).CT = 3;
% % 
% %     % ==================================================
% %     % Storm-count and severity parameters
% %     % ==================================================
% %     annualNumberOfStormsValues = [1, 3];
% % 
% %     stormDistributionParameters = struct( ...
% %         'alpha', 2, ...
% %         'theta', 0.5 ...
% %     );
% % 
% %     % =============================================
% %     % Cost model scenarios
% %     % =============================================
% %     numCostScenarios = 1;
% %     templateCostModelStruct = buildTemplateCostModelStruct();
% %     costModels = repmat(templateCostModelStruct, numCostScenarios, 1);
% % 
% %     costModels(1) = templateCostModelStruct;
% %     costModels(1).scenarioName = "debugBaselineCost";
% %     costModels(1).singlePadCAPEX = 20;
% %     costModels(1).serviceProcessCAPEXes = [5, 10, 20];
% %     costModels(1).delayCosts = [5, 10, 20];
% %     costModels(1).baseFluidCost = 1;
% %     costModels(1).baseActivationCost = 1;
% % 
% %     % =======================
% %     % Populate output struct
% %     % =======================
% %     simulationParameterGrids = struct();
% %     simulationParameterGrids.policies = policies;
% %     simulationParameterGrids.arrivalProcesses = arrivalProcesses;
% %     simulationParameterGrids.serviceProcesses = serviceProcesses;
% %     simulationParameterGrids.taxiTakeoffProcesses = taxiTakeoffProcesses;
% %     simulationParameterGrids.annualNumberOfStormsValues = annualNumberOfStormsValues;
% %     simulationParameterGrids.stormDistributionParameters = stormDistributionParameters;
% %     simulationParameterGrids.costModels = costModels;
% % end
% 
% 
% function simulationParameterGrids = buildSimulationParameterGridsForAnalyticModel()
%     % BUILDSIMULATIONPARAMETERGRIDSFORDEBUGDES Builds a fast, nonpathological DES debug grid.
%     %
%     % PURPOSE
%     %  Temporary debug-only parameter grid for testing CSV/output plumbing.
%     %  Avoids unstable HOT recirculation regimes and pathological queue growth.
% 
%     % ==================================================
%     % Policies
%     % ==================================================
%     policies = struct();
% 
%     % Keep utilization comfortably below one even for slow service.
%     policies.kValues = [6, 8];
% 
%     % Preserve all three service scenarios.
%     policies.eValues = 1:3;
% 
%     % ==================================================
%     % Arrival process scenarios
%     % ==================================================
%     numArrivalProcessScenarios = 2;
%     templateArrivalProcessStruct = buildTemplateArrivalProcessStruct();
%     arrivalProcesses = repmat(templateArrivalProcessStruct, numArrivalProcessScenarios, 1);
% 
%     arrivalProcesses(1) = templateArrivalProcessStruct;
%     arrivalProcesses(1).scenarioName = "debugVeryLightNoPeak";
%     arrivalProcesses(1).lambdaBase = 1;
%     arrivalProcesses(1).lambdaPeak = 0.35;
%     arrivalProcesses(1).t0 = 60;
%     arrivalProcesses(1).sigmaLambda = 1;
%     arrivalProcesses(1).Ca = 1;
% 
%     arrivalProcesses(2) = templateArrivalProcessStruct;
%     arrivalProcesses(2).scenarioName = "debugLightBroadPeak";
%     arrivalProcesses(2).lambdaBase = 0.35;
%     arrivalProcesses(2).lambdaPeak = 0.6;
%     arrivalProcesses(2).t0 = 120;
%     arrivalProcesses(2).sigmaLambda = 3;
%     arrivalProcesses(2).Ca = 1;
% 
%     % ==================================================
%     % Service process scenarios
%     % ==================================================
%     numServiceProcessScenarios = 3;
%     templateServiceProcessStruct = buildTemplateServiceProcessStruct();
%     serviceProcesses = repmat(templateServiceProcessStruct, numServiceProcessScenarios, 1);
% 
%     serviceProcesses(1) = templateServiceProcessStruct;
%     serviceProcesses(1).scenarioName = "baseline";
%     serviceProcesses(1).muDI = 2000;
%     serviceProcesses(1).eta = 0.1;
%     serviceProcesses(1).Cs = 1;
%     serviceProcesses(1).activationCostMultiple = 1;
%     serviceProcesses(1).serviceProcessCAPEXCase = "low";
% 
%     serviceProcesses(2) = templateServiceProcessStruct;
%     serviceProcesses(2).scenarioName = "upgraded";
%     serviceProcesses(2).muDI = 3000;
%     serviceProcesses(2).eta = 0.1;
%     serviceProcesses(2).Cs = 1;
%     serviceProcesses(2).activationCostMultiple = 1.5;
%     serviceProcesses(2).serviceProcessCAPEXCase = "medium";
% 
%     serviceProcesses(3) = templateServiceProcessStruct;
%     serviceProcesses(3).scenarioName = "highEnd";
%     serviceProcesses(3).muDI = 4000;
%     serviceProcesses(3).eta = 0.1;
%     serviceProcesses(3).Cs = 1;
%     serviceProcesses(3).activationCostMultiple = 3;
%     serviceProcesses(3).serviceProcessCAPEXCase = "high";
% 
%     % =======================================================
%     % Taxi/takeoff process scenarios
%     % =======================================================
%     numTaxiTakeoffProcessScenarios = 1;
%     templateTaxiTakeoffProcessStruct = buildTemplateTaxiTakeoffProcessStruct();
%     taxiTakeoffProcesses = repmat(templateTaxiTakeoffProcessStruct, numTaxiTakeoffProcessScenarios, 1);
% 
%     taxiTakeoffProcesses(1) = templateTaxiTakeoffProcessStruct;
%     taxiTakeoffProcesses(1).scenarioName = "debugStableTaxi";
%     taxiTakeoffProcesses(1).beta = 0.2;
%     taxiTakeoffProcesses(1).p = 1;
%     taxiTakeoffProcesses(1).T0 = 0.8;
%     taxiTakeoffProcesses(1).CT = 0.75;
% 
%     % ==================================================
%     % Storm-count and severity parameters
%     % ==================================================
%     annualNumberOfStormsValues = [1, 2];
% 
%     stormDistributionParameters = struct( ...
%         'alpha', 2, ...
%         'theta', 0.15 ...
%     );
% 
%     % =============================================
%     % Cost model scenarios
%     % =============================================
%     numCostScenarios = 1;
%     templateCostModelStruct = buildTemplateCostModelStruct();
%     costModels = repmat(templateCostModelStruct, numCostScenarios, 1);
% 
%     costModels(1) = templateCostModelStruct;
%     costModels(1).scenarioName = "debugBaselineCost";
%     costModels(1).singlePadCAPEX = 20;
%     costModels(1).serviceProcessCAPEXes = [5, 10, 20];
%     costModels(1).delayCosts = [5, 10, 20];
%     costModels(1).baseFluidCost = 1;
%     costModels(1).baseActivationCost = 1;
% 
%     % =======================
%     % Populate output struct
%     % =======================
%     simulationParameterGrids = struct();
%     simulationParameterGrids.policies = policies;
%     simulationParameterGrids.arrivalProcesses = arrivalProcesses;
%     simulationParameterGrids.serviceProcesses = serviceProcesses;
%     simulationParameterGrids.taxiTakeoffProcesses = taxiTakeoffProcesses;
%     simulationParameterGrids.annualNumberOfStormsValues = annualNumberOfStormsValues;
%     simulationParameterGrids.stormDistributionParameters = stormDistributionParameters;
%     simulationParameterGrids.costModels = costModels;
% end
function simulationParameterGrids = buildSimulationParameterGridsForAnalyticModel()
    % BUILDSIMULATIONPARAMETERGRIDSFORANALYTICMODEL Builds overnight simulation grid.
    %
    % DESIGN
    % - Conservative enough to avoid pathological DES blowups.
    % - Includes one controlled stress case to expose congestion nonlinearities.
    % - Rates are aircraft/minute and service completions/minute/server.

    % ==================================================
    % Policies
    % ==================================================
    policies = struct();
    policies.kValues = [4, 5, 6, 8];
    policies.eValues = 1:3;

    % ==================================================
    % Arrival process scenarios
    % ==================================================
    numArrivalProcessScenarios = 5;
    templateArrivalProcessStruct = buildTemplateArrivalProcessStruct();
    arrivalProcesses = repmat(templateArrivalProcessStruct, numArrivalProcessScenarios, 1);

    arrivalProcesses(1) = templateArrivalProcessStruct;
    arrivalProcesses(1).scenarioName = "steadyModerate";
    arrivalProcesses(1).lambdaBase = 0.18;
    arrivalProcesses(1).lambdaPeak = 0.00;
    arrivalProcesses(1).t0 = 180;
    arrivalProcesses(1).sigmaLambda = 1.00;
    arrivalProcesses(1).Ca = 1.00;

    arrivalProcesses(2) = templateArrivalProcessStruct;
    arrivalProcesses(2).scenarioName = "narrowDepartureBank";
    arrivalProcesses(2).lambdaBase = 0.14;
    arrivalProcesses(2).lambdaPeak = 0.32;
    arrivalProcesses(2).t0 = 180;
    arrivalProcesses(2).sigmaLambda = 0.35;
    arrivalProcesses(2).Ca = 1.00;

    arrivalProcesses(3) = templateArrivalProcessStruct;
    arrivalProcesses(3).scenarioName = "mediumDepartureBank";
    arrivalProcesses(3).lambdaBase = 0.16;
    arrivalProcesses(3).lambdaPeak = 0.28;
    arrivalProcesses(3).t0 = 180;
    arrivalProcesses(3).sigmaLambda = 1.50;
    arrivalProcesses(3).Ca = 1.00;

    arrivalProcesses(4) = templateArrivalProcessStruct;
    arrivalProcesses(4).scenarioName = "broadDepartureBank";
    arrivalProcesses(4).lambdaBase = 0.22;
    arrivalProcesses(4).lambdaPeak = 0.20;
    arrivalProcesses(4).t0 = 180;
    arrivalProcesses(4).sigmaLambda = 4.00;
    arrivalProcesses(4).Ca = 1.00;

    % Controlled stress case:
    % lambdaMax = 0.20 + 0.44 = 0.64 aircraft/min.
    % Weakest capacity = k * muDI = 4 * 0.18 = 0.72 jobs/min.
    % Peak exogenous rho = 0.64 / 0.72 = 0.889.
    arrivalProcesses(5) = templateArrivalProcessStruct;
    arrivalProcesses(5).scenarioName = "stressNarrowDepartureBank";
    arrivalProcesses(5).lambdaBase = 0.20;
    arrivalProcesses(5).lambdaPeak = 0.44;
    arrivalProcesses(5).t0 = 180;
    arrivalProcesses(5).sigmaLambda = 0.35;
    arrivalProcesses(5).Ca = 1.00;

    % ==================================================
    % Service process scenarios
    % ==================================================
    numServiceProcessScenarios = 3;
    templateServiceProcessStruct = buildTemplateServiceProcessStruct();
    serviceProcesses = repmat(templateServiceProcessStruct, numServiceProcessScenarios, 1);

    serviceProcesses(1) = templateServiceProcessStruct;
    serviceProcesses(1).scenarioName = "baseline";
    serviceProcesses(1).muDI = 0.18;
    serviceProcesses(1).eta = 0.10;
    serviceProcesses(1).Cs = 1.20;
    serviceProcesses(1).activationCostMultiple = 1.00;
    serviceProcesses(1).serviceProcessCAPEXCase = "low";

    serviceProcesses(2) = templateServiceProcessStruct;
    serviceProcesses(2).scenarioName = "upgraded";
    serviceProcesses(2).muDI = 0.24;
    serviceProcesses(2).eta = 0.08;
    serviceProcesses(2).Cs = 1.00;
    serviceProcesses(2).activationCostMultiple = 1.50;
    serviceProcesses(2).serviceProcessCAPEXCase = "medium";

    serviceProcesses(3) = templateServiceProcessStruct;
    serviceProcesses(3).scenarioName = "highEnd";
    serviceProcesses(3).muDI = 0.32;
    serviceProcesses(3).eta = 0.06;
    serviceProcesses(3).Cs = 0.80;
    serviceProcesses(3).activationCostMultiple = 2.25;
    serviceProcesses(3).serviceProcessCAPEXCase = "high";

    % =======================================================
    % Taxi/takeoff process scenarios
    % =======================================================
    numTaxiTakeoffProcessScenarios = 3;
    templateTaxiTakeoffProcessStruct = buildTemplateTaxiTakeoffProcessStruct();
    taxiTakeoffProcesses = repmat(templateTaxiTakeoffProcessStruct, numTaxiTakeoffProcessScenarios, 1);

    taxiTakeoffProcesses(1) = templateTaxiTakeoffProcessStruct;
    taxiTakeoffProcesses(1).scenarioName = "smoothTaxi";
    taxiTakeoffProcesses(1).beta = 0.20;
    taxiTakeoffProcesses(1).p = 1.00;
    taxiTakeoffProcesses(1).T0 = 8.00;
    taxiTakeoffProcesses(1).CT = 0.75;

    taxiTakeoffProcesses(2) = templateTaxiTakeoffProcessStruct;
    taxiTakeoffProcesses(2).scenarioName = "baselineTaxi";
    taxiTakeoffProcesses(2).beta = 0.45;
    taxiTakeoffProcesses(2).p = 1.25;
    taxiTakeoffProcesses(2).T0 = 10.00;
    taxiTakeoffProcesses(2).CT = 1.00;

    taxiTakeoffProcesses(3) = templateTaxiTakeoffProcessStruct;
    taxiTakeoffProcesses(3).scenarioName = "volatileTaxi";
    taxiTakeoffProcesses(3).beta = 0.80;
    taxiTakeoffProcesses(3).p = 1.50;
    taxiTakeoffProcesses(3).T0 = 12.00;
    taxiTakeoffProcesses(3).CT = 1.35;

    % ==================================================
    % Storm-count and severity parameters
    % ==================================================
    annualNumberOfStormsValues = [8, 16, 28];

    stormDistributionParameters = struct( ...
        'alpha', 2, ...
        'theta', 0.30 ...
    );

    % =============================================
    % Cost model scenarios
    % =============================================
    numCostScenarios = 3;
    templateCostModelStruct = buildTemplateCostModelStruct();
    costModels = repmat(templateCostModelStruct, numCostScenarios, 1);

    costModels(1) = templateCostModelStruct;
    costModels(1).scenarioName = "baselineCost";
    costModels(1).singlePadCAPEX = 20;
    costModels(1).serviceProcessCAPEXes = [5, 10, 20];
    costModels(1).delayCosts = [5, 10, 20];
    costModels(1).baseFluidCost = 1.00;
    costModels(1).baseActivationCost = 1.00;
    costModels(1).cancellationCost = 500;

    costModels(2) = templateCostModelStruct;
    costModels(2).scenarioName = "highFluidCost";
    costModels(2).singlePadCAPEX = 20;
    costModels(2).serviceProcessCAPEXes = [5, 10, 20];
    costModels(2).delayCosts = [5, 10, 20];
    costModels(2).baseFluidCost = 3.00;
    costModels(2).baseActivationCost = 1.00;
    costModels(2).cancellationCost = 750;

    costModels(3) = templateCostModelStruct;
    costModels(3).scenarioName = "delaySensitiveCost";
    costModels(3).singlePadCAPEX = 20;
    costModels(3).serviceProcessCAPEXes = [5, 10, 20];
    costModels(3).delayCosts = [10, 25, 60];
    costModels(3).baseFluidCost = 1.00;
    costModels(3).baseActivationCost = 1.00;
    costModels(3).cancellationCost = 1000;

    % =======================
    % Populate output struct
    % =======================
    simulationParameterGrids = struct();
    simulationParameterGrids.policies = policies;
    simulationParameterGrids.arrivalProcesses = arrivalProcesses;
    simulationParameterGrids.serviceProcesses = serviceProcesses;
    simulationParameterGrids.taxiTakeoffProcesses = taxiTakeoffProcesses;
    simulationParameterGrids.annualNumberOfStormsValues = annualNumberOfStormsValues;
    simulationParameterGrids.stormDistributionParameters = stormDistributionParameters;
    simulationParameterGrids.costModels = costModels;
end