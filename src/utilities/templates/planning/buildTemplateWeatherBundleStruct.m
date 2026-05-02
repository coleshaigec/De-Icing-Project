function templateWeatherBundleStruct = buildTemplateWeatherBundleStruct()
    % BUILDTEMPLATEWEATHERBUNDLESTRUCT Builds template weather bundle struct for preallocation.
    %
    % OUTPUT
    %  templateWeatherBundleStruct struct with fields
    %      .scenarioName (string)                  - name of weather bundle scenario
    %      .frequencyMultiplier (double)           - multiplier applied to annual storm occurrence frequencies
    %      .intensityMultiplier (double)           - multiplier applied to storm cost intensity terms
    %      .weatherProcesses array of structs      - full annual weather process bundle

    templateWeatherBundleStruct = struct();
    templateWeatherBundleStruct.scenarioName = "";
    templateWeatherBundleStruct.frequencyMultiplier = NaN;
    templateWeatherBundleStruct.intensityMultiplier = NaN;
    templateWeatherBundleStruct.weatherProcesses = buildTemplateWeatherProcessStruct();
end