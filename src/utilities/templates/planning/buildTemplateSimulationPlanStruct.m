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
    templateSimulationPlanStruct.weatherBundle = struct();
    templateSimulationPlanStruct.costModel = buildTemplateCostModelStruct();
end