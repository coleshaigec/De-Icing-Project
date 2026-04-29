function templateArrivalProcessScenarioStruct = buildTemplateArrivalProcessStruct()
    % BUILDTEMPLATEARRIVALPROCESSSCENARIOSTRUCT Builds template arrival process scenario container for preallocation.
    %
    % OUTPUT
    %  templateArrivalProcessScenarioStruct struct with fields
    %      .scenarioName
    %      .lambdaBase
    %      .lambdaPeak
    %      .t0
    %      .sigmaLambda
    %      .Ca

    templateArrivalProcessScenarioStruct = struct();

    templateArrivalProcessScenarioStruct.scenarioName = [];
    templateArrivalProcessScenarioStruct.lambdaBase = [];
    templateArrivalProcessScenarioStruct.lambdaPeak = [];
    templateArrivalProcessScenarioStruct.t0 = [];
    templateArrivalProcessScenarioStruct.sigmaLambda =[];
    templateArrivalProcessScenarioStruct.Ca = [];
end
    
    
    
    
    
    
