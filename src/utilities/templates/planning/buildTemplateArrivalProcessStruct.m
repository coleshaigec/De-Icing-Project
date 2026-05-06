% % function templateArrivalProcessScenarioStruct = buildTemplateArrivalProcessStruct()
% %     % BUILDTEMPLATEARRIVALPROCESSSTRUCT Builds template arrival process scenario container for preallocation.
% %     %
% %     % OUTPUT
% %     %  templateArrivalProcessScenarioStruct struct with fields
% %     %      .scenarioName
% %     %      .lambdaBase
% %     %      .lambdaPeak
% %     %      .t0
% %     %      .sigmaLambda
% %     %      .Ca
% % 
% %     templateArrivalProcessScenarioStruct = struct();
% % 
% %     templateArrivalProcessScenarioStruct.scenarioName = [];
% %     templateArrivalProcessScenarioStruct.lambdaBase = [];
% %     templateArrivalProcessScenarioStruct.lambdaPeak = [];
% %     templateArrivalProcessScenarioStruct.t0 = [];
% %     templateArrivalProcessScenarioStruct.sigmaLambda =[];
% %     templateArrivalProcessScenarioStruct.Ca = [];
% % end
% % 
% 
% function templateArrivalProcessScenarioStruct = buildTemplateArrivalProcessStruct()
%     % BUILDTEMPLATEARRIVALPROCESSSTRUCT Builds template arrival process scenario container for preallocation.
%     %
%     % OUTPUT
%     %  templateArrivalProcessScenarioStruct struct with fields
%     %      .scenarioName
%     %      .lambdaBase
%     %      .lambdaPeak
%     %      .t0
%     %      .sigmaLambda
%     %      .Ca
%     %      .sigmaFamily
%     %      .sigmaValue
%     %      .replicationId
%     %      .pulseMassProxy
% 
%     templateArrivalProcessScenarioStruct = struct();
% 
%     templateArrivalProcessScenarioStruct.scenarioName = "";
%     templateArrivalProcessScenarioStruct.lambdaBase = NaN;
%     templateArrivalProcessScenarioStruct.lambdaPeak = NaN;
%     templateArrivalProcessScenarioStruct.t0 = NaN;
%     templateArrivalProcessScenarioStruct.sigmaLambda = NaN;
%     templateArrivalProcessScenarioStruct.Ca = NaN;
% 
%     % Metadata only. These should not affect simulation dynamics unless
%     % downstream code explicitly uses them.
%     templateArrivalProcessScenarioStruct.sigmaFamily = "";
%     templateArrivalProcessScenarioStruct.sigmaValue = NaN;
%     templateArrivalProcessScenarioStruct.replicationId = NaN;
%     templateArrivalProcessScenarioStruct.pulseMassProxy = NaN;
% end

function templateArrivalProcessScenarioStruct = buildTemplateArrivalProcessStruct()
    % BUILDTEMPLATEARRIVALPROCESSSTRUCT Builds template arrival process scenario container for preallocation.

    templateArrivalProcessScenarioStruct = struct();

    templateArrivalProcessScenarioStruct.scenarioName = "";
    templateArrivalProcessScenarioStruct.lambdaBase = NaN;
    templateArrivalProcessScenarioStruct.lambdaPeak = NaN;
    templateArrivalProcessScenarioStruct.t0 = NaN;
    templateArrivalProcessScenarioStruct.sigmaLambda = NaN;
    templateArrivalProcessScenarioStruct.Ca = NaN;

    % Metadata only.
    templateArrivalProcessScenarioStruct.replicationIndex = NaN;
    templateArrivalProcessScenarioStruct.controlledSigmaLambda = NaN;
    templateArrivalProcessScenarioStruct.controlledPulseMassProxy = NaN;
end
