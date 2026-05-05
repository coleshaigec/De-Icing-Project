% % % % % % function simulationParameterGrids = buildSimulationParameterGridsForAnalyticModel()
% % % % % %     % BUILDSIMULATIONPARAMETERGRIDSFORANALYTICMODEL Builds controlled overnight DES grid.
% % % % % %     %
% % % % % %     % PURPOSE
% % % % % %     %  Controlled production grid for overnight runs after HOT-cancellation
% % % % % %     %  stabilization.
% % % % % %     %
% % % % % %     % DESIGN PRINCIPLES
% % % % % %     %  1. Avoid k = 1 collapse-dominated regimes in the main production grid.
% % % % % %     %  2. Preserve enough stress to observe HOT violations and cancellations.
% % % % % %     %  3. Sweep k and e jointly to expose server-count/service-rate interaction.
% % % % % %     %  4. Sweep arrival-bank temporal concentration via sigmaLambda.
% % % % % %     %  5. Sweep taxi/takeoff process behavior via baseline time, variability,
% % % % % %     %     and congestion sensitivity.
% % % % % %     %  6. Sweep storm frequency through annualNumberOfStormsValues.
% % % % % %     %  7. Sweep cost drivers with emphasis on fluid cost and delay sensitivity.
% % % % % %     %
% % % % % %     % EXPECTED GRID SIZE
% % % % % %     %  numel(kValues) * numel(eValues) * arrivals * taxi * stormCounts * costs
% % % % % %     %  = 4 * 3 * 5 * 3 * 3 * 3 = 1620 annual simulation plans.
% % % % % % 
% % % % % %     % ==================================================
% % % % % %     % Policies
% % % % % %     % ==================================================
% % % % % %     policies = struct();
% % % % % % 
% % % % % %     % k = 4 is the controlled stress lower bound.
% % % % % %     % k = 5,6 probe marginal capacity increments.
% % % % % %     % k = 8 gives an ample-capacity comparison.
% % % % % %     %
% % % % % %     % Excludes k = 1 because debug testing showed that low-capacity regimes
% % % % % %     % can become cancellation-collapse cases rather than useful operating
% % % % % %     % policies.
% % % % % %     policies.kValues = [4, 5, 6, 8];
% % % % % % 
% % % % % %     % e indexes the three service-process alternatives below.
% % % % % %     % Keep all three to study k/e interaction.
% % % % % %     policies.eValues = 1:3;
% % % % % % 
% % % % % %     % ==================================================
% % % % % %     % Arrival process scenarios
% % % % % %     % ==================================================
% % % % % %     numArrivalProcessScenarios = 5;
% % % % % %     templateArrivalProcessStruct = buildTemplateArrivalProcessStruct();
% % % % % %     arrivalProcesses = repmat(templateArrivalProcessStruct, numArrivalProcessScenarios, 1);
% % % % % % 
% % % % % %     % Steady moderate flow:
% % % % % %     % Low temporal concentration. Useful baseline.
% % % % % %     arrivalProcesses(1) = templateArrivalProcessStruct;
% % % % % %     arrivalProcesses(1).scenarioName = "steadyModerate";
% % % % % %     arrivalProcesses(1).lambdaBase = 0.18;
% % % % % %     arrivalProcesses(1).lambdaPeak = 0.00;
% % % % % %     arrivalProcesses(1).t0 = 180;
% % % % % %     arrivalProcesses(1).sigmaLambda = 1.00;
% % % % % %     arrivalProcesses(1).Ca = 1.00;
% % % % % % 
% % % % % %     % Narrow departure bank:
% % % % % %     % Same order of total demand, but temporally concentrated.
% % % % % %     arrivalProcesses(2) = templateArrivalProcessStruct;
% % % % % %     arrivalProcesses(2).scenarioName = "narrowDepartureBank";
% % % % % %     arrivalProcesses(2).lambdaBase = 0.14;
% % % % % %     arrivalProcesses(2).lambdaPeak = 0.32;
% % % % % %     arrivalProcesses(2).t0 = 180;
% % % % % %     arrivalProcesses(2).sigmaLambda = 0.35;
% % % % % %     arrivalProcesses(2).Ca = 1.00;
% % % % % % 
% % % % % %     % Medium departure bank:
% % % % % %     % Intermediate concentration.
% % % % % %     arrivalProcesses(3) = templateArrivalProcessStruct;
% % % % % %     arrivalProcesses(3).scenarioName = "mediumDepartureBank";
% % % % % %     arrivalProcesses(3).lambdaBase = 0.16;
% % % % % %     arrivalProcesses(3).lambdaPeak = 0.28;
% % % % % %     arrivalProcesses(3).t0 = 180;
% % % % % %     arrivalProcesses(3).sigmaLambda = 1.50;
% % % % % %     arrivalProcesses(3).Ca = 1.00;
% % % % % % 
% % % % % %     % Broad departure bank:
% % % % % %     % Demand spread over time. Tests whether temporal smoothing reduces
% % % % % %     % required capacity even with comparable total traffic.
% % % % % %     arrivalProcesses(4) = templateArrivalProcessStruct;
% % % % % %     arrivalProcesses(4).scenarioName = "broadDepartureBank";
% % % % % %     arrivalProcesses(4).lambdaBase = 0.22;
% % % % % %     arrivalProcesses(4).lambdaPeak = 0.20;
% % % % % %     arrivalProcesses(4).t0 = 180;
% % % % % %     arrivalProcesses(4).sigmaLambda = 4.00;
% % % % % %     arrivalProcesses(4).Ca = 1.00;
% % % % % % 
% % % % % %     % Controlled stress case:
% % % % % %     % Peak exogenous demand under weakest included policy:
% % % % % %     % lambdaMax = 0.20 + 0.44 = 0.64 aircraft/min.
% % % % % %     % weakest nominal deicing capacity = k * muDI = 4 * 0.18 = 0.72 jobs/min.
% % % % % %     % peak exogenous rho ≈ 0.889 before HOT feedback.
% % % % % %     %
% % % % % %     % This should reveal nonlinear HOT/cancellation behavior without starting
% % % % % %     % from a knowingly impossible k = 1 policy.
% % % % % %     arrivalProcesses(5) = templateArrivalProcessStruct;
% % % % % %     arrivalProcesses(5).scenarioName = "stressNarrowDepartureBank";
% % % % % %     arrivalProcesses(5).lambdaBase = 0.20;
% % % % % %     arrivalProcesses(5).lambdaPeak = 0.44;
% % % % % %     arrivalProcesses(5).t0 = 180;
% % % % % %     arrivalProcesses(5).sigmaLambda = 0.35;
% % % % % %     arrivalProcesses(5).Ca = 1.00;
% % % % % % 
% % % % % %     % ==================================================
% % % % % %     % Service process scenarios
% % % % % %     % ==================================================
% % % % % %     numServiceProcessScenarios = 3;
% % % % % %     templateServiceProcessStruct = buildTemplateServiceProcessStruct();
% % % % % %     serviceProcesses = repmat(templateServiceProcessStruct, numServiceProcessScenarios, 1);
% % % % % % 
% % % % % %     % Baseline:
% % % % % %     % Slowest service, highest variability.
% % % % % %     serviceProcesses(1) = templateServiceProcessStruct;
% % % % % %     serviceProcesses(1).scenarioName = "baseline";
% % % % % %     serviceProcesses(1).muDI = 0.18;
% % % % % %     serviceProcesses(1).eta = 0.10;
% % % % % %     serviceProcesses(1).Cs = 1.20;
% % % % % %     serviceProcesses(1).activationCostMultiple = 1.00;
% % % % % %     serviceProcesses(1).serviceProcessCAPEXCase = "low";
% % % % % % 
% % % % % %     % Upgraded:
% % % % % %     % Moderate service improvement and lower variability.
% % % % % %     serviceProcesses(2) = templateServiceProcessStruct;
% % % % % %     serviceProcesses(2).scenarioName = "upgraded";
% % % % % %     serviceProcesses(2).muDI = 0.24;
% % % % % %     serviceProcesses(2).eta = 0.08;
% % % % % %     serviceProcesses(2).Cs = 1.00;
% % % % % %     serviceProcesses(2).activationCostMultiple = 1.50;
% % % % % %     serviceProcesses(2).serviceProcessCAPEXCase = "medium";
% % % % % % 
% % % % % %     % High-end:
% % % % % %     % Fastest, least variable service. Higher activation/CAPEX burden.
% % % % % %     serviceProcesses(3) = templateServiceProcessStruct;
% % % % % %     serviceProcesses(3).scenarioName = "highEnd";
% % % % % %     serviceProcesses(3).muDI = 0.32;
% % % % % %     serviceProcesses(3).eta = 0.06;
% % % % % %     serviceProcesses(3).Cs = 0.80;
% % % % % %     serviceProcesses(3).activationCostMultiple = 2.25;
% % % % % %     serviceProcesses(3).serviceProcessCAPEXCase = "high";
% % % % % % 
% % % % % %     % ==================================================
% % % % % %     % Taxi / takeoff process scenarios
% % % % % %     % ==================================================
% % % % % %     numTaxiTakeoffProcessScenarios = 3;
% % % % % %     templateTaxiTakeoffProcessStruct = buildTemplateTaxiTakeoffProcessStruct();
% % % % % %     taxiTakeoffProcesses = repmat(templateTaxiTakeoffProcessStruct, numTaxiTakeoffProcessScenarios, 1);
% % % % % % 
% % % % % %     % Smooth taxi/takeoff:
% % % % % %     % Low congestion sensitivity and lower variability.
% % % % % %     taxiTakeoffProcesses(1) = templateTaxiTakeoffProcessStruct;
% % % % % %     taxiTakeoffProcesses(1).scenarioName = "smoothTaxi";
% % % % % %     taxiTakeoffProcesses(1).beta = 0.20;
% % % % % %     taxiTakeoffProcesses(1).p = 1.00;
% % % % % %     taxiTakeoffProcesses(1).T0 = 8.00;
% % % % % %     taxiTakeoffProcesses(1).CT = 0.75;
% % % % % % 
% % % % % %     % Baseline taxi/takeoff:
% % % % % %     % Moderate baseline time, moderate congestion sensitivity.
% % % % % %     taxiTakeoffProcesses(2) = templateTaxiTakeoffProcessStruct;
% % % % % %     taxiTakeoffProcesses(2).scenarioName = "baselineTaxi";
% % % % % %     taxiTakeoffProcesses(2).beta = 0.45;
% % % % % %     taxiTakeoffProcesses(2).p = 1.25;
% % % % % %     taxiTakeoffProcesses(2).T0 = 10.00;
% % % % % %     taxiTakeoffProcesses(2).CT = 1.00;
% % % % % % 
% % % % % %     % Volatile taxi/takeoff:
% % % % % %     % Higher baseline time, higher variability, stronger congestion feedback.
% % % % % %     % This scenario should expose HOT/cancellation sensitivity to surface
% % % % % %     % congestion after deicing.
% % % % % %     taxiTakeoffProcesses(3) = templateTaxiTakeoffProcessStruct;
% % % % % %     taxiTakeoffProcesses(3).scenarioName = "volatileTaxi";
% % % % % %     taxiTakeoffProcesses(3).beta = 0.80;
% % % % % %     taxiTakeoffProcesses(3).p = 1.50;
% % % % % %     taxiTakeoffProcesses(3).T0 = 12.00;
% % % % % %     taxiTakeoffProcesses(3).CT = 1.35;
% % % % % % 
% % % % % %     % ==================================================
% % % % % %     % Storm-count and storm-severity parameters
% % % % % %     % ==================================================
% % % % % %     % Annual storm frequency sweep.
% % % % % %     annualNumberOfStormsValues = [8, 16, 28];
% % % % % % 
% % % % % %     % Storm severity remains stochastic within each annual run.
% % % % % %     % Gamma mean = alpha * theta = 0.60.
% % % % % %     % This gives meaningful severity variation without intentionally forcing
% % % % % %     % every run into collapse.
% % % % % %     stormDistributionParameters = struct( ...
% % % % % %         'alpha', 2, ...
% % % % % %         'theta', 0.30 ...
% % % % % %     );
% % % % % % 
% % % % % %     % =============================================
% % % % % %     % Cost model scenarios
% % % % % %     % =============================================
% % % % % %     numCostScenarios = 3;
% % % % % %     templateCostModelStruct = buildTemplateCostModelStruct();
% % % % % %     costModels = repmat(templateCostModelStruct, numCostScenarios, 1);
% % % % % % 
% % % % % %     % Baseline cost:
% % % % % %     % Balanced operating-cost case.
% % % % % %     costModels(1) = templateCostModelStruct;
% % % % % %     costModels(1).scenarioName = "baselineCost";
% % % % % %     costModels(1).singlePadCAPEX = 20;
% % % % % %     costModels(1).serviceProcessCAPEXes = [5, 10, 20];
% % % % % %     costModels(1).delayCosts = [5, 10, 20];
% % % % % %     costModels(1).baseFluidCost = 1.00;
% % % % % %     costModels(1).baseActivationCost = 1.00;
% % % % % %     costModels(1).cancellationCost = 25000;
% % % % % % 
% % % % % %     % High fluid cost:
% % % % % %     % Isolates how fluid economics shift the optimal policy.
% % % % % %     costModels(2) = templateCostModelStruct;
% % % % % %     costModels(2).scenarioName = "highFluidCost";
% % % % % %     costModels(2).singlePadCAPEX = 20;
% % % % % %     costModels(2).serviceProcessCAPEXes = [5, 10, 20];
% % % % % %     costModels(2).delayCosts = [5, 10, 20];
% % % % % %     costModels(2).baseFluidCost = 3.00;
% % % % % %     costModels(2).baseActivationCost = 1.00;
% % % % % %     costModels(2).cancellationCost = 25000;
% % % % % % 
% % % % % %     % Delay-sensitive / network-sensitive cost:
% % % % % %     % Makes severe delay economically important while keeping cancellation
% % % % % %     % penalty fixed, so cancellation is not silently cheap.
% % % % % %     costModels(3) = templateCostModelStruct;
% % % % % %     costModels(3).scenarioName = "delaySensitiveCost";
% % % % % %     costModels(3).singlePadCAPEX = 20;
% % % % % %     costModels(3).serviceProcessCAPEXes = [5, 10, 20];
% % % % % %     costModels(3).delayCosts = [10, 25, 60];
% % % % % %     costModels(3).baseFluidCost = 1.00;
% % % % % %     costModels(3).baseActivationCost = 1.00;
% % % % % %     costModels(3).cancellationCost = 25000;
% % % % % % 
% % % % % %     % =======================
% % % % % %     % Populate output struct
% % % % % %     % =======================
% % % % % %     simulationParameterGrids = struct();
% % % % % %     simulationParameterGrids.policies = policies;
% % % % % %     simulationParameterGrids.arrivalProcesses = arrivalProcesses;
% % % % % %     simulationParameterGrids.serviceProcesses = serviceProcesses;
% % % % % %     simulationParameterGrids.taxiTakeoffProcesses = taxiTakeoffProcesses;
% % % % % %     simulationParameterGrids.annualNumberOfStormsValues = annualNumberOfStormsValues;
% % % % % %     simulationParameterGrids.stormDistributionParameters = stormDistributionParameters;
% % % % % %     simulationParameterGrids.costModels = costModels;
% % % % % % end
% % % % % % 
% % % % function simulationParameterGrids = buildSimulationParameterGridsForAnalyticModel()
% % % %     % BUILDSIMULATIONPARAMETERGRIDSFORANALYTICMODEL
% % % %     %
% % % %     % EXPERIMENT 1: k/e TRADEOFF PROBE
% % % %     %
% % % %     % PURPOSE
% % % %     %  This grid isolates the tradeoff between installed deicing capacity
% % % %     %  (server count k) and service-process quality (integer index e).
% % % %     %
% % % %     %  Here e is NOT continuous. It is an integer-valued selector over the
% % % %     %  three hard-coded service processes below:
% % % %     %
% % % %     %      e = 1 -> baseline service
% % % %     %      e = 2 -> upgraded service
% % % %     %      e = 3 -> high-end service
% % % %     %
% % % %     %  Therefore, this experiment asks:
% % % %     %
% % % %     %      Does the optimizer prefer more servers, better/faster service,
% % % %     %      or some mixture of both under moderate and stressful demand?
% % % %     %
% % % %     % DESIGN
% % % %     %  - Expand k moderately: [4, 5, 6, 7, 8, 10]
% % % %     %  - Preserve e = 1:3 as service-process indices.
% % % %     %  - Use two arrival regimes: medium and stress.
% % % %     %  - Hold taxi/takeoff fixed at baselineTaxi.
% % % %     %  - Use two storm-count levels: 16 and 28.
% % % %     %  - Use baseline and delay-sensitive costs.
% % % %     %
% % % %     % EXPECTED GRID SIZE
% % % %     %  6 * 3 * 2 * 1 * 2 * 2 = 144 annual simulation plans.
% % % % 
% % % %     % ==================================================
% % % %     % Policies
% % % %     % ==================================================
% % % %     policies = struct();
% % % %     policies.kValues = [4, 5, 6, 7, 8, 10];
% % % %     policies.eValues = 1:3;
% % % % 
% % % %     % ==================================================
% % % %     % Arrival process scenarios
% % % %     % ==================================================
% % % %     numArrivalProcessScenarios = 2;
% % % %     templateArrivalProcessStruct = buildTemplateArrivalProcessStruct();
% % % %     arrivalProcesses = repmat(templateArrivalProcessStruct, numArrivalProcessScenarios, 1);
% % % % 
% % % %     arrivalProcesses(1) = templateArrivalProcessStruct;
% % % %     arrivalProcesses(1).scenarioName = "mediumDepartureBank";
% % % %     arrivalProcesses(1).lambdaBase = 0.16;
% % % %     arrivalProcesses(1).lambdaPeak = 0.28;
% % % %     arrivalProcesses(1).t0 = 180;
% % % %     arrivalProcesses(1).sigmaLambda = 1.50;
% % % %     arrivalProcesses(1).Ca = 1.00;
% % % % 
% % % %     arrivalProcesses(2) = templateArrivalProcessStruct;
% % % %     arrivalProcesses(2).scenarioName = "stressNarrowDepartureBank";
% % % %     arrivalProcesses(2).lambdaBase = 0.20;
% % % %     arrivalProcesses(2).lambdaPeak = 0.44;
% % % %     arrivalProcesses(2).t0 = 180;
% % % %     arrivalProcesses(2).sigmaLambda = 0.35;
% % % %     arrivalProcesses(2).Ca = 1.00;
% % % % 
% % % %     % ==================================================
% % % %     % Service process scenarios
% % % %     % ==================================================
% % % %     numServiceProcessScenarios = 3;
% % % %     templateServiceProcessStruct = buildTemplateServiceProcessStruct();
% % % %     serviceProcesses = repmat(templateServiceProcessStruct, numServiceProcessScenarios, 1);
% % % % 
% % % %     serviceProcesses(1) = templateServiceProcessStruct;
% % % %     serviceProcesses(1).scenarioName = "baseline";
% % % %     serviceProcesses(1).muDI = 0.18;
% % % %     serviceProcesses(1).eta = 0.10;
% % % %     serviceProcesses(1).Cs = 1.20;
% % % %     serviceProcesses(1).activationCostMultiple = 1.00;
% % % %     serviceProcesses(1).serviceProcessCAPEXCase = "low";
% % % % 
% % % %     serviceProcesses(2) = templateServiceProcessStruct;
% % % %     serviceProcesses(2).scenarioName = "upgraded";
% % % %     serviceProcesses(2).muDI = 0.24;
% % % %     serviceProcesses(2).eta = 0.08;
% % % %     serviceProcesses(2).Cs = 1.00;
% % % %     serviceProcesses(2).activationCostMultiple = 1.50;
% % % %     serviceProcesses(2).serviceProcessCAPEXCase = "medium";
% % % % 
% % % %     serviceProcesses(3) = templateServiceProcessStruct;
% % % %     serviceProcesses(3).scenarioName = "highEnd";
% % % %     serviceProcesses(3).muDI = 0.32;
% % % %     serviceProcesses(3).eta = 0.06;
% % % %     serviceProcesses(3).Cs = 0.80;
% % % %     serviceProcesses(3).activationCostMultiple = 2.25;
% % % %     serviceProcesses(3).serviceProcessCAPEXCase = "high";
% % % % 
% % % %     % ==================================================
% % % %     % Taxi / takeoff process scenarios
% % % %     % ==================================================
% % % %     numTaxiTakeoffProcessScenarios = 1;
% % % %     templateTaxiTakeoffProcessStruct = buildTemplateTaxiTakeoffProcessStruct();
% % % %     taxiTakeoffProcesses = repmat(templateTaxiTakeoffProcessStruct, numTaxiTakeoffProcessScenarios, 1);
% % % % 
% % % %     taxiTakeoffProcesses(1) = templateTaxiTakeoffProcessStruct;
% % % %     taxiTakeoffProcesses(1).scenarioName = "baselineTaxi";
% % % %     taxiTakeoffProcesses(1).beta = 0.45;
% % % %     taxiTakeoffProcesses(1).p = 1.25;
% % % %     taxiTakeoffProcesses(1).T0 = 10.00;
% % % %     taxiTakeoffProcesses(1).CT = 1.00;
% % % % 
% % % %     % ==================================================
% % % %     % Storm-count and severity parameters
% % % %     % ==================================================
% % % %     annualNumberOfStormsValues = [16, 28];
% % % % 
% % % %     stormDistributionParameters = struct( ...
% % % %         'alpha', 2, ...
% % % %         'theta', 0.30 ...
% % % %     );
% % % % 
% % % %     % ==================================================
% % % %     % Cost model scenarios
% % % %     % ==================================================
% % % %     numCostScenarios = 2;
% % % %     templateCostModelStruct = buildTemplateCostModelStruct();
% % % %     costModels = repmat(templateCostModelStruct, numCostScenarios, 1);
% % % % 
% % % %     costModels(1) = templateCostModelStruct;
% % % %     costModels(1).scenarioName = "baselineCost";
% % % %     costModels(1).singlePadCAPEX = 20;
% % % %     costModels(1).serviceProcessCAPEXes = [5, 10, 20];
% % % %     costModels(1).delayCosts = [5, 10, 20];
% % % %     costModels(1).baseFluidCost = 1.00;
% % % %     costModels(1).baseActivationCost = 1.00;
% % % %     costModels(1).cancellationCost = 25000;
% % % % 
% % % %     costModels(2) = templateCostModelStruct;
% % % %     costModels(2).scenarioName = "delaySensitiveCost";
% % % %     costModels(2).singlePadCAPEX = 20;
% % % %     costModels(2).serviceProcessCAPEXes = [5, 10, 20];
% % % %     costModels(2).delayCosts = [10, 25, 60];
% % % %     costModels(2).baseFluidCost = 1.00;
% % % %     costModels(2).baseActivationCost = 1.00;
% % % %     costModels(2).cancellationCost = 25000;
% % % % 
% % % %     simulationParameterGrids = struct();
% % % %     simulationParameterGrids.policies = policies;
% % % %     simulationParameterGrids.arrivalProcesses = arrivalProcesses;
% % % %     simulationParameterGrids.serviceProcesses = serviceProcesses;
% % % %     simulationParameterGrids.taxiTakeoffProcesses = taxiTakeoffProcesses;
% % % %     simulationParameterGrids.annualNumberOfStormsValues = annualNumberOfStormsValues;
% % % %     simulationParameterGrids.stormDistributionParameters = stormDistributionParameters;
% % % %     simulationParameterGrids.costModels = costModels;
% % % % end
% % % % 
% % % % function simulationParameterGrids = buildSimulationParameterGridsForAnalyticModel()
% % % %     % BUILDSIMULATIONPARAMETERGRIDSFORANALYTICMODEL
% % % %     %
% % % %     % EXPERIMENT 2: WEATHER SENSITIVITY / SPORADIC-SPIKE ECONOMICS
% % % %     %
% % % %     % PURPOSE
% % % %     %  This grid probes how optimal deicing capacity changes when the airport
% % % %     %  faces different annual winter operating environments.
% % % %     %
% % % %     %  This is the geography-specific research question:
% % % %     %
% % % %     %      Should capacity be sized for frequent storms, rare storms,
% % % %     %      severe storms, or sporadic tail-risk events?
% % % %     %
% % % %     % DESIGN
% % % %     %  - Preserve k/e policy structure from production grid.
% % % %     %  - Use two arrival regimes:
% % % %     %       mediumDepartureBank
% % % %     %       stressNarrowDepartureBank
% % % %     %  - Hold taxi/takeoff at baselineTaxi to isolate weather sensitivity.
% % % %     %  - Sweep storm frequency broadly:
% % % %     %       4, 8, 16, 28, 40, 60 annual storms
% % % %     %  - Use one severe storm distribution to probe tail-heavy conditions.
% % % %     %
% % % %     % NOTE
% % % %     %  If time permits, rerun this exact same grid three times with:
% % % %     %
% % % %     %      theta = 0.20  mild storm severity
% % % %     %      theta = 0.30  baseline storm severity
% % % %     %      theta = 0.50  severe storm severity
% % % %     %
% % % %     %  The version below uses theta = 0.50 because severe sporadic weather is
% % % %     %  the most decision-relevant tail case.
% % % %     %
% % % %     % EXPECTED GRID SIZE
% % % %     %  4 * 3 * 2 * 1 * 6 * 1 = 144 annual simulation plans.
% % % % 
% % % %     % ==================================================
% % % %     % Policies
% % % %     % ==================================================
% % % %     policies = struct();
% % % %     policies.kValues = [4, 5, 6, 8];
% % % %     policies.eValues = 1:3;
% % % % 
% % % %     % ==================================================
% % % %     % Arrival process scenarios
% % % %     % ==================================================
% % % %     numArrivalProcessScenarios = 2;
% % % %     templateArrivalProcessStruct = buildTemplateArrivalProcessStruct();
% % % %     arrivalProcesses = repmat(templateArrivalProcessStruct, numArrivalProcessScenarios, 1);
% % % % 
% % % %     arrivalProcesses(1) = templateArrivalProcessStruct;
% % % %     arrivalProcesses(1).scenarioName = "mediumDepartureBank";
% % % %     arrivalProcesses(1).lambdaBase = 0.16;
% % % %     arrivalProcesses(1).lambdaPeak = 0.28;
% % % %     arrivalProcesses(1).t0 = 180;
% % % %     arrivalProcesses(1).sigmaLambda = 1.50;
% % % %     arrivalProcesses(1).Ca = 1.00;
% % % % 
% % % %     arrivalProcesses(2) = templateArrivalProcessStruct;
% % % %     arrivalProcesses(2).scenarioName = "stressNarrowDepartureBank";
% % % %     arrivalProcesses(2).lambdaBase = 0.20;
% % % %     arrivalProcesses(2).lambdaPeak = 0.44;
% % % %     arrivalProcesses(2).t0 = 180;
% % % %     arrivalProcesses(2).sigmaLambda = 0.35;
% % % %     arrivalProcesses(2).Ca = 1.00;
% % % % 
% % % %     % ==================================================
% % % %     % Service process scenarios
% % % %     % ==================================================
% % % %     numServiceProcessScenarios = 3;
% % % %     templateServiceProcessStruct = buildTemplateServiceProcessStruct();
% % % %     serviceProcesses = repmat(templateServiceProcessStruct, numServiceProcessScenarios, 1);
% % % % 
% % % %     serviceProcesses(1) = templateServiceProcessStruct;
% % % %     serviceProcesses(1).scenarioName = "baseline";
% % % %     serviceProcesses(1).muDI = 0.18;
% % % %     serviceProcesses(1).eta = 0.10;
% % % %     serviceProcesses(1).Cs = 1.20;
% % % %     serviceProcesses(1).activationCostMultiple = 1.00;
% % % %     serviceProcesses(1).serviceProcessCAPEXCase = "low";
% % % % 
% % % %     serviceProcesses(2) = templateServiceProcessStruct;
% % % %     serviceProcesses(2).scenarioName = "upgraded";
% % % %     serviceProcesses(2).muDI = 0.24;
% % % %     serviceProcesses(2).eta = 0.08;
% % % %     serviceProcesses(2).Cs = 1.00;
% % % %     serviceProcesses(2).activationCostMultiple = 1.50;
% % % %     serviceProcesses(2).serviceProcessCAPEXCase = "medium";
% % % % 
% % % %     serviceProcesses(3) = templateServiceProcessStruct;
% % % %     serviceProcesses(3).scenarioName = "highEnd";
% % % %     serviceProcesses(3).muDI = 0.32;
% % % %     serviceProcesses(3).eta = 0.06;
% % % %     serviceProcesses(3).Cs = 0.80;
% % % %     serviceProcesses(3).activationCostMultiple = 2.25;
% % % %     serviceProcesses(3).serviceProcessCAPEXCase = "high";
% % % % 
% % % %     % ==================================================
% % % %     % Taxi / takeoff process scenarios
% % % %     % ==================================================
% % % %     numTaxiTakeoffProcessScenarios = 1;
% % % %     templateTaxiTakeoffProcessStruct = buildTemplateTaxiTakeoffProcessStruct();
% % % %     taxiTakeoffProcesses = repmat(templateTaxiTakeoffProcessStruct, numTaxiTakeoffProcessScenarios, 1);
% % % % 
% % % %     taxiTakeoffProcesses(1) = templateTaxiTakeoffProcessStruct;
% % % %     taxiTakeoffProcesses(1).scenarioName = "baselineTaxi";
% % % %     taxiTakeoffProcesses(1).beta = 0.45;
% % % %     taxiTakeoffProcesses(1).p = 1.25;
% % % %     taxiTakeoffProcesses(1).T0 = 10.00;
% % % %     taxiTakeoffProcesses(1).CT = 1.00;
% % % % 
% % % %     % ==================================================
% % % %     % Storm-count and severity parameters
% % % %     % ==================================================
% % % %     annualNumberOfStormsValues = [4, 8, 16, 28, 40, 60];
% % % % 
% % % %     % Severe-weather version.
% % % %     % Gamma mean = alpha * theta = 1.00.
% % % %     % This intentionally probes heavier storm burden than the baseline grid.
% % % %     stormDistributionParameters = struct( ...
% % % %         'alpha', 2, ...
% % % %         'theta', 0.50 ...
% % % %     );
% % % % 
% % % %     % ==================================================
% % % %     % Cost model scenarios
% % % %     % ==================================================
% % % %     numCostScenarios = 1;
% % % %     templateCostModelStruct = buildTemplateCostModelStruct();
% % % %     costModels = repmat(templateCostModelStruct, numCostScenarios, 1);
% % % % 
% % % %     costModels(1) = templateCostModelStruct;
% % % %     costModels(1).scenarioName = "baselineCost";
% % % %     costModels(1).singlePadCAPEX = 20;
% % % %     costModels(1).serviceProcessCAPEXes = [5, 10, 20];
% % % %     costModels(1).delayCosts = [5, 10, 20];
% % % %     costModels(1).baseFluidCost = 1.00;
% % % %     costModels(1).baseActivationCost = 1.00;
% % % %     costModels(1).cancellationCost = 25000;
% % % % 
% % % %     simulationParameterGrids = struct();
% % % %     simulationParameterGrids.policies = policies;
% % % %     simulationParameterGrids.arrivalProcesses = arrivalProcesses;
% % % %     simulationParameterGrids.serviceProcesses = serviceProcesses;
% % % %     simulationParameterGrids.taxiTakeoffProcesses = taxiTakeoffProcesses;
% % % %     simulationParameterGrids.annualNumberOfStormsValues = annualNumberOfStormsValues;
% % % %     simulationParameterGrids.stormDistributionParameters = stormDistributionParameters;
% % % %     simulationParameterGrids.costModels = costModels;
% % % % end
% % % function simulationParameterGrids = buildSimulationParameterGridsForAnalyticModel()
% % %     % BUILDSIMULATIONPARAMETERGRIDSFORANALYTICMODEL
% % %     %
% % %     % EXPERIMENT 3: EXECUTIVE COST-DRIVER SENSITIVITY
% % %     %
% % %     % PURPOSE
% % %     %  This grid asks which business assumptions actually move the optimal
% % %     %  policy:
% % %     %
% % %     %      - higher delay/network externality costs
% % %     %      - fortress-hub disruption sensitivity
% % %     %      - higher cancellation penalties
% % %     %      - tighter labor market / activation cost
% % %     %      - higher fluid prices
% % %     %
% % %     %  This is the most executive-facing experiment. It asks:
% % %     %
% % %     %      If cost assumptions change, does optimal capacity change,
% % %     %      or is the physical congestion structure dominant?
% % %     %
% % %     % DESIGN
% % %     %  - Use existing k/e policy grid.
% % %     %  - Use medium and stress arrival regimes.
% % %     %  - Include baselineTaxi and volatileTaxi.
% % %     %  - Use two storm-count levels.
% % %     %  - Sweep cost models heavily while holding physical assumptions limited.
% % %     %
% % %     % EXPECTED GRID SIZE
% % %     %  4 * 3 * 2 * 2 * 2 * 7 = 672 annual simulation plans.
% % % 
% % %     % ==================================================
% % %     % Policies
% % %     % ==================================================
% % %     policies = struct();
% % %     policies.kValues = [4, 5, 6, 8];
% % %     policies.eValues = 1:3;
% % % 
% % %     % ==================================================
% % %     % Arrival process scenarios
% % %     % ==================================================
% % %     numArrivalProcessScenarios = 2;
% % %     templateArrivalProcessStruct = buildTemplateArrivalProcessStruct();
% % %     arrivalProcesses = repmat(templateArrivalProcessStruct, numArrivalProcessScenarios, 1);
% % % 
% % %     arrivalProcesses(1) = templateArrivalProcessStruct;
% % %     arrivalProcesses(1).scenarioName = "mediumDepartureBank";
% % %     arrivalProcesses(1).lambdaBase = 0.16;
% % %     arrivalProcesses(1).lambdaPeak = 0.28;
% % %     arrivalProcesses(1).t0 = 180;
% % %     arrivalProcesses(1).sigmaLambda = 1.50;
% % %     arrivalProcesses(1).Ca = 1.00;
% % % 
% % %     arrivalProcesses(2) = templateArrivalProcessStruct;
% % %     arrivalProcesses(2).scenarioName = "stressNarrowDepartureBank";
% % %     arrivalProcesses(2).lambdaBase = 0.20;
% % %     arrivalProcesses(2).lambdaPeak = 0.44;
% % %     arrivalProcesses(2).t0 = 180;
% % %     arrivalProcesses(2).sigmaLambda = 0.35;
% % %     arrivalProcesses(2).Ca = 1.00;
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
% % %     serviceProcesses(1).muDI = 0.18;
% % %     serviceProcesses(1).eta = 0.10;
% % %     serviceProcesses(1).Cs = 1.20;
% % %     serviceProcesses(1).activationCostMultiple = 1.00;
% % %     serviceProcesses(1).serviceProcessCAPEXCase = "low";
% % % 
% % %     serviceProcesses(2) = templateServiceProcessStruct;
% % %     serviceProcesses(2).scenarioName = "upgraded";
% % %     serviceProcesses(2).muDI = 0.24;
% % %     serviceProcesses(2).eta = 0.08;
% % %     serviceProcesses(2).Cs = 1.00;
% % %     serviceProcesses(2).activationCostMultiple = 1.50;
% % %     serviceProcesses(2).serviceProcessCAPEXCase = "medium";
% % % 
% % %     serviceProcesses(3) = templateServiceProcessStruct;
% % %     serviceProcesses(3).scenarioName = "highEnd";
% % %     serviceProcesses(3).muDI = 0.32;
% % %     serviceProcesses(3).eta = 0.06;
% % %     serviceProcesses(3).Cs = 0.80;
% % %     serviceProcesses(3).activationCostMultiple = 2.25;
% % %     serviceProcesses(3).serviceProcessCAPEXCase = "high";
% % % 
% % %     % ==================================================
% % %     % Taxi / takeoff process scenarios
% % %     % ==================================================
% % %     numTaxiTakeoffProcessScenarios = 2;
% % %     templateTaxiTakeoffProcessStruct = buildTemplateTaxiTakeoffProcessStruct();
% % %     taxiTakeoffProcesses = repmat(templateTaxiTakeoffProcessStruct, numTaxiTakeoffProcessScenarios, 1);
% % % 
% % %     taxiTakeoffProcesses(1) = templateTaxiTakeoffProcessStruct;
% % %     taxiTakeoffProcesses(1).scenarioName = "baselineTaxi";
% % %     taxiTakeoffProcesses(1).beta = 0.45;
% % %     taxiTakeoffProcesses(1).p = 1.25;
% % %     taxiTakeoffProcesses(1).T0 = 10.00;
% % %     taxiTakeoffProcesses(1).CT = 1.00;
% % % 
% % %     taxiTakeoffProcesses(2) = templateTaxiTakeoffProcessStruct;
% % %     taxiTakeoffProcesses(2).scenarioName = "volatileTaxi";
% % %     taxiTakeoffProcesses(2).beta = 0.80;
% % %     taxiTakeoffProcesses(2).p = 1.50;
% % %     taxiTakeoffProcesses(2).T0 = 12.00;
% % %     taxiTakeoffProcesses(2).CT = 1.35;
% % % 
% % %     % ==================================================
% % %     % Storm-count and severity parameters
% % %     % ==================================================
% % %     annualNumberOfStormsValues = [16, 28];
% % % 
% % %     stormDistributionParameters = struct( ...
% % %         'alpha', 2, ...
% % %         'theta', 0.30 ...
% % %     );
% % % 
% % %     % ==================================================
% % %     % Cost model scenarios
% % %     % ==================================================
% % %     numCostScenarios = 7;
% % %     templateCostModelStruct = buildTemplateCostModelStruct();
% % %     costModels = repmat(templateCostModelStruct, numCostScenarios, 1);
% % % 
% % %     % Baseline.
% % %     costModels(1) = templateCostModelStruct;
% % %     costModels(1).scenarioName = "baselineCost";
% % %     costModels(1).singlePadCAPEX = 20;
% % %     costModels(1).serviceProcessCAPEXes = [5, 10, 20];
% % %     costModels(1).delayCosts = [5, 10, 20];
% % %     costModels(1).baseFluidCost = 1.00;
% % %     costModels(1).baseActivationCost = 1.00;
% % %     costModels(1).cancellationCost = 25000;
% % % 
% % %     % Delay-sensitive network case.
% % %     costModels(2) = templateCostModelStruct;
% % %     costModels(2).scenarioName = "delaySensitiveCost";
% % %     costModels(2).singlePadCAPEX = 20;
% % %     costModels(2).serviceProcessCAPEXes = [5, 10, 20];
% % %     costModels(2).delayCosts = [10, 25, 60];
% % %     costModels(2).baseFluidCost = 1.00;
% % %     costModels(2).baseActivationCost = 1.00;
% % %     costModels(2).cancellationCost = 25000;
% % % 
% % %     % Fortress hub case:
% % %     % Higher delay externality and higher cancellation penalty.
% % %     costModels(3) = templateCostModelStruct;
% % %     costModels(3).scenarioName = "fortressHubCost";
% % %     costModels(3).singlePadCAPEX = 20;
% % %     costModels(3).serviceProcessCAPEXes = [5, 10, 20];
% % %     costModels(3).delayCosts = [20, 50, 120];
% % %     costModels(3).baseFluidCost = 1.00;
% % %     costModels(3).baseActivationCost = 1.00;
% % %     costModels(3).cancellationCost = 75000;
% % % 
% % %     % High cancellation penalty:
% % %     % Isolates cancellation penalty while leaving delay costs baseline.
% % %     costModels(4) = templateCostModelStruct;
% % %     costModels(4).scenarioName = "highCancellationCost";
% % %     costModels(4).singlePadCAPEX = 20;
% % %     costModels(4).serviceProcessCAPEXes = [5, 10, 20];
% % %     costModels(4).delayCosts = [5, 10, 20];
% % %     costModels(4).baseFluidCost = 1.00;
% % %     costModels(4).baseActivationCost = 1.00;
% % %     costModels(4).cancellationCost = 100000;
% % % 
% % %     % High labor / activation cost:
% % %     % Tests whether expensive staffing pushes the policy away from
% % %     % high-activation service processes.
% % %     costModels(5) = templateCostModelStruct;
% % %     costModels(5).scenarioName = "highLaborCost";
% % %     costModels(5).singlePadCAPEX = 20;
% % %     costModels(5).serviceProcessCAPEXes = [5, 10, 20];
% % %     costModels(5).delayCosts = [5, 10, 20];
% % %     costModels(5).baseFluidCost = 1.00;
% % %     costModels(5).baseActivationCost = 2.00;
% % %     costModels(5).cancellationCost = 25000;
% % % 
% % %     % Moderate fluid-price shock.
% % %     costModels(6) = templateCostModelStruct;
% % %     costModels(6).scenarioName = "highFluidCost50";
% % %     costModels(6).singlePadCAPEX = 20;
% % %     costModels(6).serviceProcessCAPEXes = [5, 10, 20];
% % %     costModels(6).delayCosts = [5, 10, 20];
% % %     costModels(6).baseFluidCost = 1.50;
% % %     costModels(6).baseActivationCost = 1.00;
% % %     costModels(6).cancellationCost = 25000;
% % % 
% % %     % Large fluid-price shock.
% % %     costModels(7) = templateCostModelStruct;
% % %     costModels(7).scenarioName = "highFluidCost3x";
% % %     costModels(7).singlePadCAPEX = 20;
% % %     costModels(7).serviceProcessCAPEXes = [5, 10, 20];
% % %     costModels(7).delayCosts = [5, 10, 20];
% % %     costModels(7).baseFluidCost = 3.00;
% % %     costModels(7).baseActivationCost = 1.00;
% % %     costModels(7).cancellationCost = 25000;
% % % 
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
% % function simulationParameterGrids = buildSimulationParameterGridsForAnalyticModel()
% %     % BUILDSIMULATIONPARAMETERGRIDSFORANALYTICMODEL
% %     %
% %     % EXPERIMENT: CONTROLLED ARRIVAL-DENSITY / SIGMALAMBDA SENSITIVITY
% %     %
% %     % PURPOSE
% %     %  This grid isolates the effect of temporal concentration in the
% %     %  exogenous departure-arrival process.
% %     %
% %     %  The arrival pulse is modeled as a Gaussian-shaped NHPP intensity
% %     %  contribution. For such a pulse, total expected pulse demand is
% %     %  approximately proportional to:
% %     %
% %     %      lambdaPeak * sigmaLambda
% %     %
% %     %  Therefore, this experiment varies sigmaLambda while inversely scaling
% %     %  lambdaPeak so that the total expected pulse mass remains approximately
% %     %  constant.
% %     %
% %     %  Lower sigmaLambda means a tighter, higher peak.
% %     %  Higher sigmaLambda means a wider, lower peak.
% %     %
% %     % DESIGN
% %     %  - Keep lambdaBase fixed.
% %     %  - Keep t0 fixed.
% %     %  - Keep lambdaPeak * sigmaLambda fixed.
% %     %  - Keep taxi/takeoff fixed.
% %     %  - Keep storm severity fixed.
% %     %  - Use multiple annual replications per sigmaLambda to reduce Monte
% %     %    Carlo noise.
% %     %
% %     % EXPECTED GRID SIZE
% %     %  4 k-values * 1 e-value * 8 sigma-values * 20 replications
% %     %  * 1 taxi scenario * 2 storm-count values * 1 cost model
% %     %  = 1280 annual simulation plans.
% %     %
% %     % NOTE
% %     %  Replications are encoded as separate arrival scenario names with
% %     %  identical physical parameters. This assumes the simulation pipeline
% %     %  draws fresh random variates for each annual simulation plan.
% % 
% %     % ==================================================
% %     % Policies
% %     % ==================================================
% %     policies = struct();
% % 
% %     policies.kValues = [4, 5, 6, 8];
% % 
% %     % Fix e = 3 to isolate arrival-density effects under the strongest
% %     % service process observed in the policy experiments.
% %     % e is an integer service-process index, not a continuous parameter.
% %     policies.eValues = 3;
% % 
% %     % ==================================================
% %     % Arrival process scenarios
% %     % ==================================================
% %     sigmaLambdaValues = [0.25, 0.35, 0.50, 0.75, 1.00, 1.50, 2.50, 4.00];
% %     numReplications = 20;
% % 
% %     numArrivalProcessScenarios = numel(sigmaLambdaValues) * numReplications;
% %     templateArrivalProcessStruct = buildTemplateArrivalProcessStruct();
% %     arrivalProcesses = repmat(templateArrivalProcessStruct, numArrivalProcessScenarios, 1);
% % 
% %     lambdaBase = 0.18;
% %     peakTime = 180;
% %     arrivalCV = 1.00;
% % 
% %     % Constant pulse mass proxy.
% %     % Calibrated so sigmaLambda = 1.00 corresponds to lambdaPeak = 0.36.
% %     pulseMassProxy = 0.36;
% % 
% %     iScenario = 0;
% % 
% %     for iSigma = 1:numel(sigmaLambdaValues)
% %         sigmaLambda = sigmaLambdaValues(iSigma);
% %         lambdaPeak = pulseMassProxy / sigmaLambda;
% % 
% %         for iReplication = 1:numReplications
% %             iScenario = iScenario + 1;
% % 
% %             arrivalProcesses(iScenario) = templateArrivalProcessStruct;
% %             arrivalProcesses(iScenario).scenarioName = sprintf( ...
% %                 "sigmaControlled_%s_rep%02d", ...
% %                 replace(string(sprintf("%.2f", sigmaLambda)), ".", "p"), ...
% %                 iReplication);
% % 
% %             arrivalProcesses(iScenario).lambdaBase = lambdaBase;
% %             arrivalProcesses(iScenario).lambdaPeak = lambdaPeak;
% %             arrivalProcesses(iScenario).t0 = peakTime;
% %             arrivalProcesses(iScenario).sigmaLambda = sigmaLambda;
% %             arrivalProcesses(iScenario).Ca = arrivalCV;
% %         end
% %     end
% % 
% %     assert(iScenario == numArrivalProcessScenarios, ...
% %         "buildSimulationParameterGridsForAnalyticModel:ArrivalScenarioCountMismatch", ...
% %         "Expected %d arrival scenarios but constructed %d.", ...
% %         numArrivalProcessScenarios, iScenario);
% % 
% %     % ==================================================
% %     % Service process scenarios
% %     % ==================================================
% %     numServiceProcessScenarios = 3;
% %     templateServiceProcessStruct = buildTemplateServiceProcessStruct();
% %     serviceProcesses = repmat(templateServiceProcessStruct, numServiceProcessScenarios, 1);
% % 
% %     serviceProcesses(1) = templateServiceProcessStruct;
% %     serviceProcesses(1).scenarioName = "baseline";
% %     serviceProcesses(1).muDI = 0.18;
% %     serviceProcesses(1).eta = 0.10;
% %     serviceProcesses(1).Cs = 1.20;
% %     serviceProcesses(1).activationCostMultiple = 1.00;
% %     serviceProcesses(1).serviceProcessCAPEXCase = "low";
% % 
% %     serviceProcesses(2) = templateServiceProcessStruct;
% %     serviceProcesses(2).scenarioName = "upgraded";
% %     serviceProcesses(2).muDI = 0.24;
% %     serviceProcesses(2).eta = 0.08;
% %     serviceProcesses(2).Cs = 1.00;
% %     serviceProcesses(2).activationCostMultiple = 1.50;
% %     serviceProcesses(2).serviceProcessCAPEXCase = "medium";
% % 
% %     serviceProcesses(3) = templateServiceProcessStruct;
% %     serviceProcesses(3).scenarioName = "highEnd";
% %     serviceProcesses(3).muDI = 0.32;
% %     serviceProcesses(3).eta = 0.06;
% %     serviceProcesses(3).Cs = 0.80;
% %     serviceProcesses(3).activationCostMultiple = 2.25;
% %     serviceProcesses(3).serviceProcessCAPEXCase = "high";
% % 
% %     % ==================================================
% %     % Taxi / takeoff process scenarios
% %     % ==================================================
% %     numTaxiTakeoffProcessScenarios = 1;
% %     templateTaxiTakeoffProcessStruct = buildTemplateTaxiTakeoffProcessStruct();
% %     taxiTakeoffProcesses = repmat(templateTaxiTakeoffProcessStruct, numTaxiTakeoffProcessScenarios, 1);
% % 
% %     taxiTakeoffProcesses(1) = templateTaxiTakeoffProcessStruct;
% %     taxiTakeoffProcesses(1).scenarioName = "baselineTaxi";
% %     taxiTakeoffProcesses(1).beta = 0.45;
% %     taxiTakeoffProcesses(1).p = 1.25;
% %     taxiTakeoffProcesses(1).T0 = 10.00;
% %     taxiTakeoffProcesses(1).CT = 1.00;
% % 
% %     % ==================================================
% %     % Storm-count and storm-severity parameters
% %     % ==================================================
% %     annualNumberOfStormsValues = [16, 28];
% % 
% %     stormDistributionParameters = struct( ...
% %         'alpha', 2, ...
% %         'theta', 0.30 ...
% %     );
% % 
% %     % ==================================================
% %     % Cost model scenarios
% %     % ==================================================
% %     numCostScenarios = 1;
% %     templateCostModelStruct = buildTemplateCostModelStruct();
% %     costModels = repmat(templateCostModelStruct, numCostScenarios, 1);
% % 
% %     costModels(1) = templateCostModelStruct;
% %     costModels(1).scenarioName = "baselineCost";
% %     costModels(1).singlePadCAPEX = 20;
% %     costModels(1).serviceProcessCAPEXes = [5, 10, 20];
% %     costModels(1).delayCosts = [5, 10, 20];
% %     costModels(1).baseFluidCost = 1.00;
% %     costModels(1).baseActivationCost = 1.00;
% %     costModels(1).cancellationCost = 25000;
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
% function simulationParameterGrids = buildSimulationParameterGridsForAnalyticModel()
%     % BUILDSIMULATIONPARAMETERGRIDSFORANALYTICMODEL
%     %
%     % EXPERIMENT: HIGH-UTILIZATION CONTROLLED SIGMALAMBDA SENSITIVITY
%     %
%     % PURPOSE
%     %  This grid tests whether arrival-bank concentration matters once the
%     %  system is pushed closer to critical utilization.
%     %
%     %  The previous controlled sigmaLambda experiment held pulse mass fixed
%     %  but used high service quality and relatively generous capacity. That
%     %  design showed weak sigmaLambda effects, suggesting the system could
%     %  absorb temporal redistribution when not near the congestion boundary.
%     %
%     %  This experiment keeps the same controlled-arrival logic but deliberately
%     %  lowers the capacity/service margin so that narrow peaks can interact
%     %  with queueing, HOT recirculation, and cancellations.
%     %
%     % CONTROL LOGIC
%     %  For a Gaussian-shaped NHPP arrival pulse, expected pulse mass is
%     %  approximately proportional to:
%     %
%     %      lambdaPeak * sigmaLambda
%     %
%     %  Therefore, this grid varies sigmaLambda while setting:
%     %
%     %      lambdaPeak = pulseMassProxy / sigmaLambda
%     %
%     %  This holds total pulse demand approximately constant while changing
%     %  temporal concentration.
%     %
%     % DESIGN
%     %  - Lower k range: [2, 3, 4, 5]
%     %  - Fix e = 1 to use the baseline service process.
%     %  - Keep lambdaBase, t0, taxi/takeoff, storm severity, and costs fixed.
%     %  - Use 20 replications per sigmaLambda value.
%     %
%     % EXPECTED GRID SIZE
%     %  4 k-values * 1 e-value * 8 sigma-values * 20 replications
%     %  * 1 taxi scenario * 2 storm-count values * 1 cost model
%     %  = 1280 annual simulation plans.
% 
%     % ==================================================
%     % Policies
%     % ==================================================
%     policies = struct();
% 
%     % Lower-capacity range chosen to reveal near-critical behavior.
%     % k = 2 is intentionally stressful but not as degenerate as k = 1.
%     policies.kValues = [2, 3, 4, 5];
% 
%     % Fix e = 1 to test sigmaLambda sensitivity under the weakest service
%     % process. e is an integer index into the service process array.
%     policies.eValues = 1;
% 
%     % ==================================================
%     % Arrival process scenarios
%     % ==================================================
%     sigmaLambdaValues = [0.25, 0.35, 0.50, 0.75, 1.00, 1.50, 2.50, 4.00];
%     numReplications = 20;
% 
%     numArrivalProcessScenarios = numel(sigmaLambdaValues) * numReplications;
%     templateArrivalProcessStruct = buildTemplateArrivalProcessStruct();
%     arrivalProcesses = repmat(templateArrivalProcessStruct, numArrivalProcessScenarios, 1);
% 
%     % Baseline demand lifted moderately relative to the previous controlled
%     % experiment to keep broad-pulse cases nontrivial.
%     lambdaBase = 0.22;
%     peakTime = 180;
%     arrivalCV = 1.00;
% 
%     % Constant pulse mass proxy.
%     % sigmaLambda = 1.00 corresponds to lambdaPeak = 0.42.
%     pulseMassProxy = 0.42;
% 
%     iScenario = 0;
% 
%     for iSigma = 1:numel(sigmaLambdaValues)
%         sigmaLambda = sigmaLambdaValues(iSigma);
%         lambdaPeak = pulseMassProxy / sigmaLambda;
% 
%         for iReplication = 1:numReplications
%             iScenario = iScenario + 1;
% 
%             arrivalProcesses(iScenario) = templateArrivalProcessStruct;
%             arrivalProcesses(iScenario).scenarioName = sprintf( ...
%                 "sigmaHighUtil_%s_rep%02d", ...
%                 replace(string(sprintf("%.2f", sigmaLambda)), ".", "p"), ...
%                 iReplication);
% 
%             arrivalProcesses(iScenario).lambdaBase = lambdaBase;
%             arrivalProcesses(iScenario).lambdaPeak = lambdaPeak;
%             arrivalProcesses(iScenario).t0 = peakTime;
%             arrivalProcesses(iScenario).sigmaLambda = sigmaLambda;
%             arrivalProcesses(iScenario).Ca = arrivalCV;
%         end
%     end
% 
%     assert(iScenario == numArrivalProcessScenarios, ...
%         "buildSimulationParameterGridsForAnalyticModel:ArrivalScenarioCountMismatch", ...
%         "Expected %d arrival scenarios but constructed %d.", ...
%         numArrivalProcessScenarios, iScenario);
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
%     serviceProcesses(1).muDI = 0.18;
%     serviceProcesses(1).eta = 0.10;
%     serviceProcesses(1).Cs = 1.20;
%     serviceProcesses(1).activationCostMultiple = 1.00;
%     serviceProcesses(1).serviceProcessCAPEXCase = "low";
% 
%     serviceProcesses(2) = templateServiceProcessStruct;
%     serviceProcesses(2).scenarioName = "upgraded";
%     serviceProcesses(2).muDI = 0.24;
%     serviceProcesses(2).eta = 0.08;
%     serviceProcesses(2).Cs = 1.00;
%     serviceProcesses(2).activationCostMultiple = 1.50;
%     serviceProcesses(2).serviceProcessCAPEXCase = "medium";
% 
%     serviceProcesses(3) = templateServiceProcessStruct;
%     serviceProcesses(3).scenarioName = "highEnd";
%     serviceProcesses(3).muDI = 0.32;
%     serviceProcesses(3).eta = 0.06;
%     serviceProcesses(3).Cs = 0.80;
%     serviceProcesses(3).activationCostMultiple = 2.25;
%     serviceProcesses(3).serviceProcessCAPEXCase = "high";
% 
%     % ==================================================
%     % Taxi / takeoff process scenarios
%     % ==================================================
%     numTaxiTakeoffProcessScenarios = 1;
%     templateTaxiTakeoffProcessStruct = buildTemplateTaxiTakeoffProcessStruct();
%     taxiTakeoffProcesses = repmat(templateTaxiTakeoffProcessStruct, numTaxiTakeoffProcessScenarios, 1);
% 
%     taxiTakeoffProcesses(1) = templateTaxiTakeoffProcessStruct;
%     taxiTakeoffProcesses(1).scenarioName = "baselineTaxi";
%     taxiTakeoffProcesses(1).beta = 0.45;
%     taxiTakeoffProcesses(1).p = 1.25;
%     taxiTakeoffProcesses(1).T0 = 10.00;
%     taxiTakeoffProcesses(1).CT = 1.00;
% 
%     % ==================================================
%     % Storm-count and storm-severity parameters
%     % ==================================================
%     annualNumberOfStormsValues = [16, 28];
% 
%     stormDistributionParameters = struct( ...
%         'alpha', 2, ...
%         'theta', 0.30 ...
%     );
% 
%     % ==================================================
%     % Cost model scenarios
%     % ==================================================
%     numCostScenarios = 1;
%     templateCostModelStruct = buildTemplateCostModelStruct();
%     costModels = repmat(templateCostModelStruct, numCostScenarios, 1);
% 
%     costModels(1) = templateCostModelStruct;
%     costModels(1).scenarioName = "baselineCost";
%     costModels(1).singlePadCAPEX = 20;
%     costModels(1).serviceProcessCAPEXes = [5, 10, 20];
%     costModels(1).delayCosts = [5, 10, 20];
%     costModels(1).baseFluidCost = 1.00;
%     costModels(1).baseActivationCost = 1.00;
%     costModels(1).cancellationCost = 25000;
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
    % BUILDSIMULATIONPARAMETERGRIDSFORANALYTICMODEL
    %
    % EXPERIMENT: CALIBRATED CAPACITY-PLANNING GRID
    %
    % PURPOSE
    %  This grid replaces the previous cancellation-dominated production
    %  grids with a calibrated design intended to expose operational tradeoffs
    %  without placing most scenarios in HOT-recirculation collapse.
    %
    %  The prior CSVs showed that cancellation cost dominated roughly 99% of
    %  operating cost in many scenarios. That made fluid-cost, delay-cost,
    %  storm-frequency, arrival-density, and k/e tradeoff conclusions fragile.
    %
    %  This grid therefore:
    %      1. Removes very low-capacity policies k = 2 and k = 3.
    %      2. Removes the extreme stress case with lambdaMax near 0.64.
    %      3. Keeps moderate stress so HOT violations can still occur.
    %      4. Balances cancellation, delay, fluid, and activation costs.
    %      5. Preserves a full factorial structure for clean comparisons.
    %
    % DESIGN QUESTIONS
    %  1. How do airports trade off number of pads k and service process e?
    %  2. How does arrival-bank shape affect congestion when total demand is
    %     kept in a more physically sensible range?
    %  3. How does taxi/takeoff variability affect HOT recirculation?
    %  4. How does storm frequency affect optimal capacity?
    %  5. How do fluid, delay, and cancellation economics move the optimum?
    %
    % EXPECTED GRID SIZE
    %  5 k-values * 3 e-values * 4 arrivals * 3 taxi scenarios
    %  * 3 storm-count values * 4 cost models = 2160 annual simulation plans.

    % ==================================================
    % Policies
    % ==================================================
    policies = struct();

    % k = 4 remains the lower bound for controlled stress.
    % k = 10 gives a high-capacity reference without making the grid huge.
    policies.kValues = [4, 5, 6, 8, 10];

    % e indexes the three service-process alternatives below:
    %   e = 1 -> baseline
    %   e = 2 -> upgraded
    %   e = 3 -> highEnd
    policies.eValues = 1:3;

    % ==================================================
    % Arrival process scenarios
    % ==================================================
    numArrivalProcessScenarios = 4;
    templateArrivalProcessStruct = buildTemplateArrivalProcessStruct();
    arrivalProcesses = repmat(templateArrivalProcessStruct, numArrivalProcessScenarios, 1);

    % Scenario 1: steady moderate demand.
    % Purpose: low-concentration baseline with no bank pulse.
    arrivalProcesses(1) = templateArrivalProcessStruct;
    arrivalProcesses(1).scenarioName = "steadyModerate";
    arrivalProcesses(1).lambdaBase = 0.14;
    arrivalProcesses(1).lambdaPeak = 0.00;
    arrivalProcesses(1).t0 = 180;
    arrivalProcesses(1).sigmaLambda = 1.00;
    arrivalProcesses(1).Ca = 1.00;

    % Scenario 2: broad bank.
    % Purpose: same qualitative demand class as banked operations, but spread.
    arrivalProcesses(2) = templateArrivalProcessStruct;
    arrivalProcesses(2).scenarioName = "broadModerateBank";
    arrivalProcesses(2).lambdaBase = 0.14;
    arrivalProcesses(2).lambdaPeak = 0.16;
    arrivalProcesses(2).t0 = 180;
    arrivalProcesses(2).sigmaLambda = 4.00;
    arrivalProcesses(2).Ca = 1.00;

    % Scenario 3: medium bank.
    % Purpose: central operating case.
    arrivalProcesses(3) = templateArrivalProcessStruct;
    arrivalProcesses(3).scenarioName = "mediumModerateBank";
    arrivalProcesses(3).lambdaBase = 0.14;
    arrivalProcesses(3).lambdaPeak = 0.22;
    arrivalProcesses(3).t0 = 180;
    arrivalProcesses(3).sigmaLambda = 1.50;
    arrivalProcesses(3).Ca = 1.00;

    % Scenario 4: narrow controlled stress bank.
    % Purpose: stress case below prior collapse-driving intensity.
    %
    % Previous stress case:
    %   lambdaBase = 0.20, lambdaPeak = 0.44, lambdaMax = 0.64
    %
    % New stress case:
    %   lambdaBase = 0.14, lambdaPeak = 0.28, lambdaMax = 0.42
    %
    % Weakest included nominal deicing capacity:
    %   k = 4, e = 1 -> 4 * 0.18 = 0.72 jobs/min
    %
    % Peak exogenous rho before HOT feedback:
    %   0.42 / 0.72 = 0.583
    %
    % This should create queueing pressure without making recirculation the
    % entire experiment.
    arrivalProcesses(4) = templateArrivalProcessStruct;
    arrivalProcesses(4).scenarioName = "narrowControlledStressBank";
    arrivalProcesses(4).lambdaBase = 0.14;
    arrivalProcesses(4).lambdaPeak = 0.28;
    arrivalProcesses(4).t0 = 180;
    arrivalProcesses(4).sigmaLambda = 0.50;
    arrivalProcesses(4).Ca = 1.00;

    % ==================================================
    % Service process scenarios
    % ==================================================
    numServiceProcessScenarios = 3;
    templateServiceProcessStruct = buildTemplateServiceProcessStruct();
    serviceProcesses = repmat(templateServiceProcessStruct, numServiceProcessScenarios, 1);

    % Baseline service.
    serviceProcesses(1) = templateServiceProcessStruct;
    serviceProcesses(1).scenarioName = "baseline";
    serviceProcesses(1).muDI = 0.18;
    serviceProcesses(1).eta = 0.10;
    serviceProcesses(1).Cs = 1.20;
    serviceProcesses(1).activationCostMultiple = 1.00;
    serviceProcesses(1).serviceProcessCAPEXCase = "low";

    % Upgraded service.
    serviceProcesses(2) = templateServiceProcessStruct;
    serviceProcesses(2).scenarioName = "upgraded";
    serviceProcesses(2).muDI = 0.24;
    serviceProcesses(2).eta = 0.08;
    serviceProcesses(2).Cs = 1.00;
    serviceProcesses(2).activationCostMultiple = 1.50;
    serviceProcesses(2).serviceProcessCAPEXCase = "medium";

    % High-end service.
    serviceProcesses(3) = templateServiceProcessStruct;
    serviceProcesses(3).scenarioName = "highEnd";
    serviceProcesses(3).muDI = 0.32;
    serviceProcesses(3).eta = 0.06;
    serviceProcesses(3).Cs = 0.80;
    serviceProcesses(3).activationCostMultiple = 2.25;
    serviceProcesses(3).serviceProcessCAPEXCase = "high";

    % ==================================================
    % Taxi / takeoff process scenarios
    % ==================================================
    numTaxiTakeoffProcessScenarios = 3;
    templateTaxiTakeoffProcessStruct = buildTemplateTaxiTakeoffProcessStruct();
    taxiTakeoffProcesses = repmat(templateTaxiTakeoffProcessStruct, numTaxiTakeoffProcessScenarios, 1);

    % Smooth taxi/takeoff.
    % Purpose: favorable downstream surface condition.
    taxiTakeoffProcesses(1) = templateTaxiTakeoffProcessStruct;
    taxiTakeoffProcesses(1).scenarioName = "smoothTaxi";
    taxiTakeoffProcesses(1).beta = 0.20;
    taxiTakeoffProcesses(1).p = 1.00;
    taxiTakeoffProcesses(1).T0 = 8.00;
    taxiTakeoffProcesses(1).CT = 0.75;

    % Baseline taxi/takeoff.
    % Purpose: central downstream condition.
    taxiTakeoffProcesses(2) = templateTaxiTakeoffProcessStruct;
    taxiTakeoffProcesses(2).scenarioName = "baselineTaxi";
    taxiTakeoffProcesses(2).beta = 0.40;
    taxiTakeoffProcesses(2).p = 1.20;
    taxiTakeoffProcesses(2).T0 = 10.00;
    taxiTakeoffProcesses(2).CT = 1.00;

    % Moderately volatile taxi/takeoff.
    % Purpose: preserve downstream-sensitivity test while avoiding the prior
    % extreme volatileTaxi setting that helped drive mass cancellations.
    %
    % Previous volatileTaxi:
    %   beta = 0.80, p = 1.50, T0 = 12.00, CT = 1.35
    %
    % New volatileTaxi:
    %   beta = 0.60, p = 1.35, T0 = 11.00, CT = 1.20
    taxiTakeoffProcesses(3) = templateTaxiTakeoffProcessStruct;
    taxiTakeoffProcesses(3).scenarioName = "volatileTaxi";
    taxiTakeoffProcesses(3).beta = 0.60;
    taxiTakeoffProcesses(3).p = 1.35;
    taxiTakeoffProcesses(3).T0 = 11.00;
    taxiTakeoffProcesses(3).CT = 1.20;

    % ==================================================
    % Storm-count and storm-severity parameters
    % ==================================================
    % Storm frequency sweep.
    % 8  = mild winter
    % 16 = baseline winter
    % 28 = active winter
    annualNumberOfStormsValues = [8, 16, 28];

    % Lower storm severity than the prior main production grid.
    %
    % Previous baseline:
    %   alpha = 2, theta = 0.30, mean severity = 0.60
    %
    % New calibrated severity:
    %   alpha = 2, theta = 0.20, mean severity = 0.40
    %
    % This preserves stochastic weather variation but reduces the probability
    % that almost every scenario enters cancellation collapse.
    stormDistributionParameters = struct( ...
        'alpha', 2, ...
        'theta', 0.20 ...
    );

    % ==================================================
    % Cost model scenarios
    % ==================================================
    numCostScenarios = 4;
    templateCostModelStruct = buildTemplateCostModelStruct();
    costModels = repmat(templateCostModelStruct, numCostScenarios, 1);

    % Cost model 1: balanced baseline.
    %
    % Cancellation remains expensive, but no longer overwhelms the objective
    % by construction. Delay costs are raised relative to the old baseline so
    % delay behavior can actually affect the optimum.
    costModels(1) = templateCostModelStruct;
    costModels(1).scenarioName = "balancedBaselineCost";
    costModels(1).singlePadCAPEX = 20;
    costModels(1).serviceProcessCAPEXes = [5, 10, 20];
    costModels(1).delayCosts = [20, 50, 120];
    costModels(1).baseFluidCost = 2.00;
    costModels(1).baseActivationCost = 10.00;
    costModels(1).cancellationCost = 10000;

    % Cost model 2: delay-sensitive network.
    %
    % Tests whether high network-delay externalities favor larger k, better e,
    % or both.
    costModels(2) = templateCostModelStruct;
    costModels(2).scenarioName = "delaySensitiveCost";
    costModels(2).singlePadCAPEX = 20;
    costModels(2).serviceProcessCAPEXes = [5, 10, 20];
    costModels(2).delayCosts = [40, 100, 250];
    costModels(2).baseFluidCost = 2.00;
    costModels(2).baseActivationCost = 10.00;
    costModels(2).cancellationCost = 10000;

    % Cost model 3: high-fluid-cost environment.
    %
    % Tests whether expensive deicing fluid shifts the optimum toward fewer
    % repeated deicing jobs, faster service, or more capacity.
    costModels(3) = templateCostModelStruct;
    costModels(3).scenarioName = "highFluidCost";
    costModels(3).singlePadCAPEX = 20;
    costModels(3).serviceProcessCAPEXes = [5, 10, 20];
    costModels(3).delayCosts = [20, 50, 120];
    costModels(3).baseFluidCost = 8.00;
    costModels(3).baseActivationCost = 10.00;
    costModels(3).cancellationCost = 10000;

    % Cost model 4: high-cancellation-penalty case.
    %
    % Keeps cancellation penalty high enough to test robustness, but avoids
    % the old 75000/100000 cases that made cancellation mechanically dominate.
    costModels(4) = templateCostModelStruct;
    costModels(4).scenarioName = "highCancellationCost";
    costModels(4).singlePadCAPEX = 20;
    costModels(4).serviceProcessCAPEXes = [5, 10, 20];
    costModels(4).delayCosts = [20, 50, 120];
    costModels(4).baseFluidCost = 2.00;
    costModels(4).baseActivationCost = 10.00;
    costModels(4).cancellationCost = 20000;

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