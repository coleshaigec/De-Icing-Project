function templateServiceProcessStruct = buildTemplateServiceProcessStruct()
    % BUILDTEMPLATESERVICEPROCESSSTRUCT Builds template service process struct for preallocation.
    %
    % OUTPUT
    %  templateServiceProcessStruct struct with fields
    %      .scenarioName (string)                  - name of chosen service process scenario
    %      .muDI (nonnegative double)              - de-icing service rate
    %      .eta (nonnegative double)               - congestion propagation parameter
    %      .Cs (nonnegative double)                - coefficient of variation of service process
    %      .activationCostMultiple (double)        - scenario-specific resource activation cost multiplier
    %      .serviceProcessCAPEXCase (string)       - "low", "medium", or "high"

    templateServiceProcessStruct = struct();
    templateServiceProcessStruct.scenarioName = [];
    templateServiceProcessStruct.muDI = [];
    templateServiceProcessStruct.eta = [];
    templateServiceProcessStruct.Cs = [];
    templateServiceProcessStruct.activationCostMultiple = [];
    templateServiceProcessStruct.serviceProcessCAPEXCase = [];
end