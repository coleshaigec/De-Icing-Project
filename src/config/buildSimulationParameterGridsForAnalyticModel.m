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
    %          .duration (double)                      - number of hours for which specified storm type persists
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

    policies = struct();
    policies.kValues = 1:8;
    policies.eValues = 1:3;

    % ==================================================
    % Arrival process scenarios
    % ==================================================
    numArrivalProcessScenarios = 3;
    templateArrivalProcessStruct = buildTemplateArrivalProcessStruct();
    arrivalProcesses = repmat(templateArrivalProcessStruct, numArrivalProcessScenarios, 1);

    arrivalProcesses(1) = templateArrivalProcessStruct;
    arrivalProcesses(1).scenarioName = "noPeak";
    arrivalProcesses(1).lambdaBase = 3;
    arrivalProcesses(1).lambdaPeak = 0;
    arrivalProcesses(1).t0 = 1;
    arrivalProcesses(1).sigmaLambda = 1;
    arrivalProcesses(1).Ca = 1;

    arrivalProcesses(2) = templateArrivalProcessStruct;
    arrivalProcesses(2).scenarioName = "narrowPeak";
    arrivalProcesses(2).lambdaBase = 3;
    arrivalProcesses(2).lambdaPeak = 6;
    arrivalProcesses(2).t0 = 200;
    arrivalProcesses(2).sigmaLambda = 0.2;
    arrivalProcesses(2).Ca = 1;

    arrivalProcesses(3) = templateArrivalProcessStruct;
    arrivalProcesses(3).scenarioName = "broadPeak";
    arrivalProcesses(3).lambdaBase = 3;
    arrivalProcesses(3).lambdaPeak = 6;
    arrivalProcesses(3).t0 = 200;
    arrivalProcesses(3).sigmaLambda = 8;
    arrivalProcesses(3).Ca = 1;

    % ==================================================
    % Service process scenarios
    % ==================================================
    numServiceProcessScenarios = 3;
    templateServiceProcessStruct = buildTemplateServiceProcessStruct();
    serviceProcesses = repmat(templateServiceProcessStruct, numServiceProcessScenarios, 1);

    serviceProcesses(1) = templateServiceProcessStruct;
    serviceProcesses(1).scenarioName = "baseline";
    serviceProcesses(1).muDI = 0.1;
    serviceProcesses(1).eta = 0.1;
    serviceProcesses(1).Cs = 1;
    serviceProcesses(1).activationCostMultiple = 1;
    serviceProcesses(1).serviceProcessCAPEXCase = "low";

    serviceProcesses(2) = templateServiceProcessStruct;
    serviceProcesses(2).scenarioName = "upgraded";
    serviceProcesses(2).muDI = 0.2;
    serviceProcesses(2).eta = 0.1;
    serviceProcesses(2).Cs = 1;
    serviceProcesses(2).activationCostMultiple = 1.5;
    serviceProcesses(2).serviceProcessCAPEXCase = "medium";

    serviceProcesses(3) = templateServiceProcessStruct;
    serviceProcesses(3).scenarioName = "highEnd";
    serviceProcesses(3).muDI = 0.4;
    serviceProcesses(3).eta = 0.1;
    serviceProcesses(3).Cs = 1;
    serviceProcesses(3).activationCostMultiple = 3;
    serviceProcesses(3).serviceProcessCAPEXCase = "high";

    % =======================================================
    % Taxi/takeoff process scenarios
    % =======================================================
    numTaxiTakeoffProcessScenarios = 3;
    templateTaxiTakeoffProcessStruct = buildTemplateTaxiTakeoffProcessStruct();
    taxiTakeoffProcesses = repmat(templateTaxiTakeoffProcessStruct, numTaxiTakeoffProcessScenarios, 1);

    taxiTakeoffProcesses(1) = templateTaxiTakeoffProcessStruct;
    taxiTakeoffProcesses(1).scenarioName = "baseline";
    taxiTakeoffProcesses(1).beta = 0.4;
    taxiTakeoffProcesses(1).p = 1;
    taxiTakeoffProcesses(1).T0 = 10;
    taxiTakeoffProcesses(1).CT = 3;

    taxiTakeoffProcesses(2) = templateTaxiTakeoffProcessStruct;
    taxiTakeoffProcesses(2).scenarioName = "congestionSensitive";
    taxiTakeoffProcesses(2).beta = 2;
    taxiTakeoffProcesses(2).p = 2;
    taxiTakeoffProcesses(2).T0 = 5;
    taxiTakeoffProcesses(2).CT = 3;

    taxiTakeoffProcesses(3) = templateTaxiTakeoffProcessStruct;
    taxiTakeoffProcesses(3).scenarioName = "largeHub";
    taxiTakeoffProcesses(3).beta = 1;
    taxiTakeoffProcesses(3).p = 3 / 2;
    taxiTakeoffProcesses(3).T0 = 15;
    taxiTakeoffProcesses(3).CT = 3;

    % ==================================================
    % Weather process baseline bundle
    % ==================================================
    numWeatherProcesses = 4;
    templateWeatherProcessStruct = buildTemplateWeatherProcessStruct();
    baselineWeatherProcesses = repmat(templateWeatherProcessStruct, numWeatherProcesses, 1);

    baselineWeatherProcesses(1) = templateWeatherProcessStruct;
    baselineWeatherProcesses(1).scenarioName = "mildStorm";
    baselineWeatherProcesses(1).numOccurrences = 20;
    baselineWeatherProcesses(1).fluidCostMultiple = 1;
    baselineWeatherProcesses(1).activationCostMultiple = 1;

    baselineWeatherProcesses(2) = templateWeatherProcessStruct;
    baselineWeatherProcesses(2).scenarioName = "moderateStorm";
    baselineWeatherProcesses(2).numOccurrences = 10;
    baselineWeatherProcesses(2).fluidCostMultiple = 2;
    baselineWeatherProcesses(2).activationCostMultiple = 2;

    baselineWeatherProcesses(3) = templateWeatherProcessStruct;
    baselineWeatherProcesses(3).scenarioName = "severeStorm";
    baselineWeatherProcesses(3).numOccurrences = 5;
    baselineWeatherProcesses(3).fluidCostMultiple = 3;
    baselineWeatherProcesses(3).activationCostMultiple = 3;

    baselineWeatherProcesses(4) = templateWeatherProcessStruct;
    baselineWeatherProcesses(4).scenarioName = "extremeStorm";
    baselineWeatherProcesses(4).numOccurrences = 2;
    baselineWeatherProcesses(4).fluidCostMultiple = 4;
    baselineWeatherProcesses(4).activationCostMultiple = 5;

    % ==================================================
    % Weather bundle sweeps
    % ==================================================
    weatherFrequencyMultipliers = [0.5, 1.0, 1.5, 2.0];
    weatherIntensityMultipliers = [1.0, 1.5, 2.0];

    numWeatherBundles = numel(weatherFrequencyMultipliers) * numel(weatherIntensityMultipliers);

    templateWeatherBundleStruct = buildTemplateWeatherBundleStruct();
    templateWeatherBundleStruct.weatherProcesses = baselineWeatherProcesses;

    weatherBundles = repmat(templateWeatherBundleStruct, numWeatherBundles, 1);

    weatherBundleIndex = 0;

    for iFrequency = 1:numel(weatherFrequencyMultipliers)
        for iIntensity = 1:numel(weatherIntensityMultipliers)
            weatherBundleIndex = weatherBundleIndex + 1;

            frequencyMultiplier = weatherFrequencyMultipliers(iFrequency);
            intensityMultiplier = weatherIntensityMultipliers(iIntensity);

            weatherProcesses = baselineWeatherProcesses;

            for iWeatherProcess = 1:numel(weatherProcesses)
                weatherProcesses(iWeatherProcess).numOccurrences = ...
                    frequencyMultiplier * weatherProcesses(iWeatherProcess).numOccurrences;

                weatherProcesses(iWeatherProcess).fluidCostMultiple = ...
                    intensityMultiplier * weatherProcesses(iWeatherProcess).fluidCostMultiple;

                weatherProcesses(iWeatherProcess).activationCostMultiple = ...
                    intensityMultiplier * weatherProcesses(iWeatherProcess).activationCostMultiple;
            end

            weatherBundles(weatherBundleIndex) = templateWeatherBundleStruct;
            weatherBundles(weatherBundleIndex).scenarioName = ...
                "freq" + string(frequencyMultiplier) + "_intensity" + string(intensityMultiplier);
            weatherBundles(weatherBundleIndex).frequencyMultiplier = frequencyMultiplier;
            weatherBundles(weatherBundleIndex).intensityMultiplier = intensityMultiplier;
            weatherBundles(weatherBundleIndex).weatherProcesses = weatherProcesses;
        end
    end

    % =============================================
    % Cost model scenarios
    % =============================================
    numCostScenarios = 5;
    templateCostModelStruct = buildTemplateCostModelStruct();
    costModels = repmat(templateCostModelStruct, numCostScenarios, 1);

    costModels(1) = templateCostModelStruct;
    costModels(1).scenarioName = "baseline";
    costModels(1).singlePadCAPEX = 20;
    costModels(1).serviceProcessCAPEXes = [5, 10, 20];
    costModels(1).delayCosts = [5, 10, 20];
    costModels(1).baseFluidCost = 1;
    costModels(1).baseActivationCost = 1;

    costModels(2) = templateCostModelStruct;
    costModels(2).scenarioName = "externalitySensitive";
    costModels(2).singlePadCAPEX = 20;
    costModels(2).serviceProcessCAPEXes = [5, 10, 20];
    costModels(2).delayCosts = [10, 20, 40];
    costModels(2).baseFluidCost = 1;
    costModels(2).baseActivationCost = 1;

    costModels(3) = templateCostModelStruct;
    costModels(3).scenarioName = "tightLaborMarket";
    costModels(3).singlePadCAPEX = 20;
    costModels(3).serviceProcessCAPEXes = [5, 10, 20];
    costModels(3).delayCosts = [5, 10, 20];
    costModels(3).baseFluidCost = 1;
    costModels(3).baseActivationCost = 5;

    costModels(4) = templateCostModelStruct;
    costModels(4).scenarioName = "highCAPEX";
    costModels(4).singlePadCAPEX = 30;
    costModels(4).serviceProcessCAPEXes = [10, 15, 25];
    costModels(4).delayCosts = [5, 10, 20];
    costModels(4).baseFluidCost = 1;
    costModels(4).baseActivationCost = 1;

    costModels(5) = templateCostModelStruct;
    costModels(5).scenarioName = "highFluidCost";
    costModels(5).singlePadCAPEX = 20;
    costModels(5).serviceProcessCAPEXes = [5, 10, 20];
    costModels(5).delayCosts = [5, 10, 20];
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
    simulationParameterGrids.weatherBundles = weatherBundles;
    simulationParameterGrids.costModels = costModels;
end