function templateCostModelStruct = buildTemplateCostModelStruct()
    % BUILDTEMPLATECOSTMODELSTRUCT Builds template costModel struct for preallocation.
    %
    % OUTPUT
    %  templateCostModelStruct struct with fields
    %          .scenarioName (string)                  - name of chosen cost scenario
    %          .singlePadCAPEX (nonnegative double)    - initial capital outlay to build a single pad
    %          .serviceProcessCAPEXes (doubles)        - initial capital outlay for equipment and other inputs in each service process scenario
    %          .delayCosts (doubles)                   - escalating piecewise linear delay cost terms [CD1, CD2, CD3]
    %          .baseFluidCost (double)                 - base fluid cost
    %          .baseActivationCost (double)            - base resource activation cost
 
    templateCostModelStruct = struct();
    templateCostModelStruct.scenarioName = [];
    templateCostModelStruct.singlePadCAPEX = [];
    templateCostModelStruct.serviceProcessCAPEXes = [];
    templateCostModelStruct.delayCosts = [];
    templateCostModelStruct.baseFluidCost = [];
    templateCostModelStruct.baseActivationCost = [];

end