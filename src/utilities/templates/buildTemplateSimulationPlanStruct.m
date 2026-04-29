function templateSimulationPlanStruct = buildTemplateSimulationPlanStruct()
    % BUILDTEMPLATESIMULATIONPLANSTRUCT Builds template simulation plan struct for preallocation.
    %
    % OUTPUT
    %  templateSimulationPlanStruct struct with fields
    %      .policy struct with fields
    %          .k (positive integer)                   - number of de-icing pads
    %          .e (integer in [1,3])                   - chosen service process scenario
    %      .arrivalProcess struct with fields
    %          .scenarioName (string)                  - name of chosen arrival process scenario
    %          .lambdaBase (nonnegative double)        - baseline arrival rates
    %          .lambdaPeak (nonnegative double)        - peak arrival rates
    %          .t0 (positive integer)                  - arrival pulse peak times
    %          .sigmaLambda (nonnegative double)       - arrival pulse tapering coefficients
    %          .Ca (nonnegative double)                - arrival pulse coefficients of variation
    %      .serviceProcess struct with fields
    %          .scenarioName (string)                  - name of chosen service process scenario
    %          .muDI (nonnegative float)               - scenario-specific de-icing service rates                   
    %          .eta (nonnegative float)                - de-icing -> taxi/takeoff congestion propagation parameters
    %          .Cs (nonnegative float)                 - de-icing process coefficient of variation
    %          .activationCostMultiple (double)        - scenario-specific resource activation cost multiplier
    %          .serviceProcessCAPEXCase (string)       - "low", "medium", or "high"
    %      .taxiTakeoffProcess struct with fields
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
    %      .costModel struct with fields
    %          .scenarioName (string)                  - name of chosen cost scenario
    %          .singlePadCAPEX (nonnegative double)    - initial capital outlay to build a single pad
    %          .serviceProcessCAPEXes (doubles)        - initial capital outlay for equipment and other inputs in each service process scenario
    %          .delayCosts (doubles)                   - escalating piecewise linear delay cost terms [CD1, CD2, CD3]
    %          .baseFluidCost (double)                 - base fluid cost
    %          .baseActivationCost (double)            - base resource activation cost
    function templateSimulationPlanStruct = buildTemplateSimulationPlanStruct()
    % BUILDTEMPLATESIMULATIONPLANSTRUCT Builds template simulation plan struct for preallocation.
    %
    % OUTPUT
    %  templateSimulationPlanStruct struct with fields
    %      .policy struct with fields
    %          .k (positive integer)                   - number of de-icing pads
    %          .e (integer in [1,3])                   - chosen service process scenario
    %      .arrivalProcess struct                     - chosen arrival process scenario
    %      .serviceProcess struct                     - chosen service process scenario
    %      .taxiTakeoffProcess struct                 - chosen taxi/takeoff process scenario
    %      .weatherProcesses array of structs         - weather process scenario bundle
    %      .costModel struct                          - chosen cost scenario

    policy = struct();
    policy.k = [];
    policy.e = [];

    templateSimulationPlanStruct = struct();
    templateSimulationPlanStruct.policy = policy;
    templateSimulationPlanStruct.arrivalProcess = buildTemplateArrivalProcessStruct();
    templateSimulationPlanStruct.serviceProcess = buildTemplateServiceProcessStruct();
    templateSimulationPlanStruct.taxiTakeoffProcess = buildTemplateTaxiTakeoffProcessStruct();
    templateSimulationPlanStruct.weatherProcesses = buildTemplateWeatherProcessStruct();
    templateSimulationPlanStruct.costModel = buildTemplateCostModelStruct();
end
end