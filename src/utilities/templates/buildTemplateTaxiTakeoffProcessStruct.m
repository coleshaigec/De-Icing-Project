function templateTaxiTakeoffProcessStruct = buildTemplateTaxiTakeoffProcessStruct()
    % BUILDTEMPLATETAXITAKEOFFPROCESSSTRUCT Builds template taxi/takeoff process struct for preallocation.
    %
    % OUTPUT
    %  templateTaxiTakeoffProcessStruct struct with fields
    %      .scenarioName (string)                  - name of chosen departure process scenario
    %      .beta (nonnegative double)              - congestion scaling parameter
    %      .p (nonnegative double)                 - congestion explosion parameter
    %      .T0 (nonnegative double)                - baseline taxi/takeoff sojourn time (minutes)
    %      .CT (nonnegative double)                - coefficient of variation of taxi/takeoff process

    templateTaxiTakeoffProcessStruct = struct();
    templateTaxiTakeoffProcessStruct.scenarioName = [];
    templateTaxiTakeoffProcessStruct.beta = [];
    templateTaxiTakeoffProcessStruct.p = [];
    templateTaxiTakeoffProcessStruct.T0 = [];
    templateTaxiTakeoffProcessStruct.CT = [];
end