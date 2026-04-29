function templateWeatherProcessStruct = buildTemplateWeatherProcessStruct()
    % BUILDTEMPLATEWEATHERPROCESSSTRUCT Builds template weather process struct for preallocation.
    %
    % OUTPUT
    %  templateWeatherProcessStruct struct with fields
    %      .scenarioName (string)                  - name of weather process scenario
    %      .numOccurrences (double)                - annual scenario occurrence frequency
    %      .fluidCostMultiple (string)             - scenario-specific fluid cost multiplier 
    %      .activationCostMultiple (double)        - scenario-specific resource activation cost multiplier
    
    templateWeatherProcessStruct = struct();
    templateWeatherProcessStruct.scenarioName = [];
    templateWeatherProcessStruct.numOccurrences = [];
    templateWeatherProcessStruct.fluidCostMultiple = [];
    templateWeatherProcessStruct.activationCostMultiple = [];
end