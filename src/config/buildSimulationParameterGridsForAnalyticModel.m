function simulationParameterGrids = buildSimulationParameterGridsForAnalyticModel()
    % BUILDSIMULATIONPARAMETERGRIDS Builds parameter grids for simulation runs that use the analytic model.
    %
    % OUTPUT
    %  simulationParameterGrids struct with fields
    %      .policies struct with fields
    %          .kValues (array of positive integers)   - chosen number of servers
    %          .eValues (array of integers in [1,3])   - chosen service rate scenarios
    %      .arrivalProcesses array of structs, each with fields
    %          .scenarioName (string)                  - name of chosen arrival process scenario
    %          .lambdaBase (nonnegative double)        - baseline arrival rates
    %          .lambdaPeak (nonnegative double)        - peak arrival rates
    %          .t0 (positive integer)                  - arrival pulse peak times
    %          .sigmaLambda (nonnegative double)       - arrival pulse tapering coefficients
    %          .Ca (nonnegative double)                - arrival pulse coefficients of variation
    %      .serviceProcesses array of structs, each with fields
    %          .scenarioName (string)                  - name of chosen service process scenario
    %          .muDI (nonnegative float)               - scenario-specific de-icing service rates                   
    %          .eta (nonnegative float)                - de-icing -> taxi/takeoff congestion propagation parameters
    %          .Cs (nonnegative float)                 - de-icing process coefficient of variation
    %          .activationCostMultiple (double)        - scenario-specific resource activation cost multiplier
    %          .serviceProcessCAPEXCase (string)       - "low", "medium", or "high"
    %      .taxiTakeoffProcesses array of structs, each with fields
    %          .scenarioName (string)                  - name of chosen departure process scenario
    %          .beta                                   - taxi/takeoff sojourn time congestion scaling parameter
    %          .p                                      - taxi/takeoff sojourn time congestion explosion parameter
    %          .T0                                     - baseline (zero-congestion) taxi/takeoff sojourn time (minutes)
    %          .CT                                     - taxi/takeoff sojourn time coefficient of variation
    %      .weatherProcesses array of structs, each with fields
    %          .scenarioName (string)                  - name of weather process scenario
    %          .numOccurrences (double)                - annual scenario occurrence frequency
    %          .fluidCostMultiple (string)             - scenario-specific fluid cost multiplier 
    %          .activationCostMultiple (double)        - scenario-specific resource activation cost multiplier
    %      .costModel array of structs, each with fields
    %          .scenarioName (string)                  - name of chosen cost scenario
    %          .singlePadCAPEX (nonnegative double)    - initial capital outlay to build a single pad
    %          .serviceProcessCAPEXes (doubles)        - initial capital outlay for equipment and other inputs in each service process scenario
    %          .delayCosts (doubles)                   - escalating piecewise linear delay cost terms [CD1, CD2, CD3]
    %          .baseFluidCost (double)                 - base fluid cost
    %          .baseActivationCost (double)            - base resource activation cost
    %      
    % NOTES
    % - This file is a global configuration utility that allows the user to
    % adjust simulation parameters as they desire. Changing the values
    % hard-coded in this file enables exploration of different policies and
    % sensitivities of results to key system parameters.
    % - Fluid costs are treated as weather-specific parameters and are thus 
    % assumed to be independent of the chosen service process scenario. 
    % - Delay costs capture geographically dispersed network externalities and are 
    % thus assumed to be independent of the chosen weather scenario.

    % ===========================================
    % Enumerate and configure candidate policies 
    % ===========================================
    policies = struct();
    policies.kValues = 1:8;
    policies.eValues = 1:3; % service rate scenarios are fixed - don't change this

    % ==================================================
    % Enumerate and configure arrival process scenarios
    % ==================================================
    numArrivalProcessScenarios = 3;
    templateArrivalProcessScenarioStruct = buildTemplateArrivalProcessScenarioStruct();

    arrivalProcesses = repmat(templateArrivalProcessScenarioStruct, numArrivalProcessScenarios, 1);

    % -- First scenario: flat arrivals with no peak --
    % This scenario acts as a baseline to understand system behavior without large de-icing arrival transients
    arrivalProcesses(1) = templateArrivalProcessScenarioStruct;
    arrivalProcesses(1).scenarioName = "noPeak";
    arrivalProcesses(1).lambdaBase = 3;
    arrivalProcesses(1).lambdaPeak = 0;
    arrivalProcesses(1).t0 = 1;
    arrivalProcesses(1).sigmaLambda = 1;
    arrivalProcesses(1).Ca = 1;

    % -- Second scenario: low flat rate with large and narrow peak --
    % This scenario acts as a test of system robustness against large de-icing arrival transients
    arrivalProcesses(2) = templateArrivalProcessScenarioStruct;
    arrivalProcesses(2).scenarioName = "narrowPeak";
    arrivalProcesses(2).lambdaBase = 3;
    arrivalProcesses(2).lambdaPeak = 6;
    arrivalProcesses(2).t0 = 200;
    arrivalProcesses(2).sigmaLambda = 0.2;
    arrivalProcesses(2).Ca = 1;

    % -- Third scenario: low flat rate with large and long-lived peak -- 
    % This scenario tests system robustness under a sustained and large-amplitude airport departure bank
    % Such large departure banks are not uncommon at major hub airports
    arrivalProcesses(3) = templateArrivalProcessScenarioStruct;
    arrivalProcesses(3).scenarioName = "broadPeak";
    arrivalProcesses(3).lambdaBase = 3;
    arrivalProcesses(3).lambdaPeak = 6;
    arrivalProcesses(3).t0 = 200;
    arrivalProcesses(3).sigmaLambda = 8;
    arrivalProcesses(3).Ca = 1;

    % ==================================================
    % Enumerate and configure service process scenarios
    % ==================================================
    numServiceProcessScenarios = 3;
    templateServiceProcessScenarioStruct = buildTemplateServiceProcessScenarioStruct();

    serviceProcesses = repmat(templateServiceProcessScenarioStruct, numServiceProcessScenarios, 1);

    % -- First scenario: low-cost baseline --
    serviceProcesses(1) = templateServiceProcessScenarioStruct;
    serviceProcesses(1).scenarioName = "baseline";
    serviceProcesses(1).muDI = 0.1;
    serviceProcesses(1).eta = 0.1;
    serviceProcesses(1).Cs = 1;
    serviceProcesses(1).activationCostMultiple = 1;
    serviceProcesses(1).serviceProcessCAPEXCase = "low";

    % -- Second scenario: upgraded service infrastructure --
    serviceProcesses(2) = templateServiceProcessScenarioStruct;
    serviceProcesses(2).scenarioName = "upgraded";
    serviceProcesses(2).muDI = 0.2;
    serviceProcesses(2).eta = 0.1;
    serviceProcesses(2).Cs = 1;
    serviceProcesses(2).activationCostMultiple = 1.5;
    serviceProcesses(2).serviceProcessCAPEXCase = "medium";

    % -- Third scenario: heavy-duty de-icing infrastructure --
    serviceProcesses(3) = templateServiceProcessScenarioStruct;
    serviceProcesses(3).scenarioName = "highEnd";
    serviceProcesses(3).muDI = 0.4;
    serviceProcesses(3).eta = 0.1;
    serviceProcesses(3).Cs = 1;
    serviceProcesses(3).activationCostMultiple = 3;
    serviceProcesses(3).serviceProcessCAPEXCase = "high";

    % =======================================================
    % Enumerate and configure taxi/takeoff process scenarios
    % =======================================================

    numTaxiTakeoffProcessScenarios = 3;
    templateTaxiTakeoffProcessScenarioStruct = buildTemplateTaxiTakeoffProcessScenarioStruct();

    taxiTakeoffProcesses = repmat(templateTaxiTakeoffProcessScenarioStruct, numTaxiTakeoffProcessScenarios, 1);

    % -- First scenario: baseline --
    taxiTakeoffProcesses(1) = templateTaxiTakeoffProcessScenarioStruct;
    taxiTakeoffProcesses(1).scenarioName = "baseline";
    taxiTakeoffProcesses(1).beta = 0.4;
    taxiTakeoffProcesses(1).p = 1;
    taxiTakeoffProcesses(1).T0 = 10;
    taxiTakeoffProcesses(1).CT = 3;

    % -- Second scenario: small airport footprint, limited runway capacity --
    % This models airports with low baseline taxi/takeoff times but high
    % congestion sensitivity due to limited runway capacity
    taxiTakeoffProcesses(2) = templateTaxiTakeoffProcessScenarioStruct;
    taxiTakeoffProcesses(2).scenarioName = "congestionSensitive";
    taxiTakeoffProcesses(2).beta = 2;
    taxiTakeoffProcesses(2).p = 2;
    taxiTakeoffProcesses(2).T0 = 5;
    taxiTakeoffProcesses(2).CT = 3;
    
    % -- Third scenario: large hub airport --
    % This scenario models a major hub airport with a large physical
    % footprint, long baseline taxi times, and moderate congestion sensitivity
    taxiTakeoffProcesses(3) = templateTaxiTakeoffProcessScenarioStruct;
    taxiTakeoffProcesses(3).scenarioName = "largeHub";
    taxiTakeoffProcesses(3).beta = 1;
    taxiTakeoffProcesses(3).p = 3/2;
    taxiTakeoffProcesses(3).T0 = 15;
    taxiTakeoffProcesses(3).CT = 3;

    % ==================================================
    % Enumerate and configure weather process scenarios
    % ==================================================
    % NOTES
    % - Meteorological modeling is outside the scope of this study.
    % - This predefined set of weather events is imposed, with annual
    % frequency specified as heuristic approximations rather than estimates
    % from empirical data.
    % - Adjustments may be made to frequencies and cost multiples to
    % simulate different airport locales and operating conditions.


    numWeatherProcesses = 4;
    templateWeatherProcessStruct = buildTemplateWeatherProcessStruct();

    weatherProcesses = repmat(templateWeatherProcessStruct, numWeatherProcesses, 1);

    % -- First scenario: baseline --
    weatherProcesses(1) = templateWeatherProcessStruct;
    weatherProcesses(1).scenarioName = "mildStorm";
    weatherProcesses(1).numOccurrences = 20;
    weatherProcesses(1).fluidCostMultiple = 1;
    weatherProcesses(1).activationCostMultiple = 1;

    % -- Second scenario: moderate storm --
    weatherProcesses(2) = templateWeatherProcessStruct;
    weatherProcesses(2).scenarioName = "moderateStorm";
    weatherProcesses(2).numOccurrences = 10;
    weatherProcesses(2).fluidCostMultiple = 2;
    weatherProcesses(2).activationCostMultiple = 2;

    % -- Third scenario: severe storm --
    weatherProcesses(3) = templateWeatherProcessStruct;
    weatherProcesses(3).scenarioName = "severeStorm";
    weatherProcesses(3).numOccurrences = 5;
    weatherProcesses(3).fluidCostMultiple = 3;
    weatherProcesses(3).activationCostMultiple = 3;

    % -- Fourth scenario: extreme event --
    weatherProcesses(4) = templateWeatherProcessStruct;
    weatherProcesses(4).scenarioName = "extremeStorm";
    weatherProcesses(4).numOccurrences = 2;
    weatherProcesses(4).fluidCostMultiple = 4;
    weatherProcesses(4).activationCostMultiple = 5;

    % =============================================
    % Enumerate and configure cost model scenarios
    % =============================================

    numCostScenarios = 5;
    templateCostModelStruct = buildTemplateCostModelStruct();

    costModels = repmat(templateCostModelStruct, numCostScenarios, 1);

    % -- First scenario: baseline --
    costModels(1) = templateCostModelStruct;
    costModels(1).scenarioName = "baseline";
    costModels(1).singlePadCAPEX = 20;
    costModels(1).serviceProcessCAPEXes = [5, 10, 20]; 
    costModels(1).delayCosts = [5,10,20];
    costModels(1).baseFluidCost = 1;
    costModels(1).baseActivationCost = 1;

    % -- Second scenario: baseline + high sensitivity to network externalities --
    % This scenario models hub airports with large, tightly-coupled
    % networks that are strongly sensitive to delays
    costModels(2) = templateCostModelStruct;
    costModels(2).scenarioName = "externalitySensitive";
    costModels(2).singlePadCAPEX = 20;
    costModels(2).serviceProcessCAPEXes = [5, 10, 20]; 
    costModels(2).delayCosts = [10,20,40];
    costModels(2).baseFluidCost = 1;
    costModels(2).baseActivationCost = 1;

    % -- Third scenario: tight labor market --
    % This scenario models an airport that faces high labor costs
    costModels(3) = templateCostModelStruct;
    costModels(3).scenarioName = "tightLaborMarket";
    costModels(3).singlePadCAPEX = 20;
    costModels(3).serviceProcessCAPEXes = [5, 10, 20]; 
    costModels(3).delayCosts = [5,10,20];
    costModels(3).baseFluidCost = 1;
    costModels(3).baseActivationCost = 5;

    % -- Fourth scenario: high-CAPEX airport --
    % This scenario models an airport with high cost of capital and
    % baseline variable OPEX.
    costModels(4) = templateCostModelStruct;
    costModels(4).scenarioName = "highCAPEX";
    costModels(4).singlePadCAPEX = 30;
    costModels(4).serviceProcessCAPEXes = [10, 15, 25]; 
    costModels(4).delayCosts = [5,10,20];
    costModels(4).baseFluidCost = 1;
    costModels(4).baseActivationCost = 1;

    % -- Fifth scenario: high fluid costs --
    % This scenario models an airport facing high fluid costs.
    costModels(5) = templateCostModelStruct;
    costModels(5).scenarioName = "highFluidCost";
    costModels(5).singlePadCAPEX = 20;
    costModels(5).serviceProcessCAPEXes = [5, 10, 20]; 
    costModels(5).delayCosts = [5,10,20];
    costModels(5).baseFluidCost = 5;
    costModels(5).baseActivationCost = 1;

    % =======================
    % Populate output struct
    % =======================
    simulationParameterGrids = struct();
    simulationParameterGrids.policies = policies;
    simulationParameterGrids.arrivalProcesses = arrivalProcesses;
    simulationParameterGrids.serviceProcesses = serviceProcesses;
    simulationParameterGrids.taxiTakeoffProcesses = taxiTakeoffProcesses;
    simulationParameterGrids.weatherProcesses = weatherProcesses;
    simulationParameterGrids.costModels = costModels;
end