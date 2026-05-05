function outputFilePath = writeSimulationResultsToCSV(simulationResults)
    % WRITESIMULATIONRESULTSTOCSV Writes paired annual DES/analytic results to CSV.

    arguments
        simulationResults (:, 1) struct
    end

    if isempty(simulationResults)
        error("writeSimulationResultsToCSV:EmptyInput", ...
            "simulationResults must be nonempty.");
    end

    projectRoot = findProjectRoot();
    outputDirectory = fullfile(projectRoot, "outputs");

    if ~isfolder(outputDirectory)
        mkdir(outputDirectory);
    end

    timestamp = string(datetime("now", "Format", "yyyyMMdd_HHmmss"));
    outputFileName = "annual_simulation_results_" + timestamp + ".csv";
    outputFilePath = fullfile(outputDirectory, outputFileName);

    numRows = 2 * numel(simulationResults);
    resultsTable = initializeResultsTable(numRows);

    rowIndex = 0;

    for idxResult = 1:numel(simulationResults)
        rowIndex = rowIndex + 1;
        rowTable = buildSimulationResultTableRow( ...
            simulationResults(idxResult).DES, ...
            simulationResults(idxResult).simulationPlan, ...
            "DES");
        rowTable.runIndex = idxResult;
        resultsTable(rowIndex, :) = rowTable;

        rowIndex = rowIndex + 1;
        rowTable = buildSimulationResultTableRow( ...
            simulationResults(idxResult).analyticModel, ...
            simulationResults(idxResult).simulationPlan, ...
            "analyticModel");
        rowTable.runIndex = idxResult;
        resultsTable(rowIndex, :) = rowTable;
    end

    writetable(resultsTable, outputFilePath);
end

function resultsTable = initializeResultsTable(numRows)
    variableNames = [
        "runIndex"
        "modelType"
        "numDays"

        "policyK"
        "policyE"

        "arrivalScenarioName"
        "serviceScenarioName"
        "taxiTakeoffScenarioName"
        "costScenarioName"

        "annualNumberOfStorms"

        "totalExternalArrivals"
        "totalDepartures"
        "totalCancellations"
        "totalDeicingJobs"
        "totalHOTViolations"

        "meanExternalArrivalsPerDay"
        "stdExternalArrivalsPerDay"
        "p95ExternalArrivalsPerDay"
        "maxExternalArrivalsPerDay"

        "meanDeparturesPerDay"
        "meanCancellationsPerDay"
        "stdCancellationsPerDay"
        "p90CancellationsPerDay"
        "p95CancellationsPerDay"
        "p99CancellationsPerDay"
        "maxCancellationsPerDay"
        "numDaysWithCancellations"
        "cancellationRatePerExternalAircraft"
        "meanDailyCancellationRate"

        "meanDeicingJobsPerDay"
        "stdDeicingJobsPerDay"
        "p95DeicingJobsPerDay"
        "maxDeicingJobsPerDay"
        "meanHOTViolationsPerDay"
        "p95HOTViolationsPerDay"
        "maxHOTViolationsPerDay"
        "numDaysWithHOTViolations"
        "meanDeicingJobsPerExternalAircraft"
        "hotViolationRatePerExternalAircraft"
        "hotViolationRatePerDeicingJob"

        "totalDeicingQueueingDelay"
        "totalDeicingServiceTime"
        "meanDeicingQueueingDelayAcrossDays"
        "stdMeanDeicingQueueingDelayAcrossDays"
        "p95MeanDeicingQueueingDelayAcrossDays"
        "meanDeicingServiceTimeAcrossDays"
        "stdMeanDeicingServiceTimeAcrossDays"
        "p95MeanDeicingServiceTimeAcrossDays"
        "meanDailyP95DeicingQueueingDelay"
        "p95DailyP95DeicingQueueingDelay"
        "meanDailyP95DeicingServiceTime"
        "p95DailyP95DeicingServiceTime"

        "totalTaxiTakeoffQueueingDelay"
        "totalTaxiTakeoffServiceTime"
        "totalTaxiTakeoffSojournTime"
        "meanTaxiTakeoffQueueingDelayAcrossDays"
        "stdMeanTaxiTakeoffQueueingDelayAcrossDays"
        "meanTaxiTakeoffServiceTimeAcrossDays"
        "meanTaxiTakeoffSojournTimeAcrossDays"
        "stdMeanTaxiTakeoffSojournTimeAcrossDays"
        "p95MeanTaxiTakeoffSojournTimeAcrossDays"
        "meanDailyP95TaxiTakeoffSojournTime"
        "p95DailyP95TaxiTakeoffSojournTime"

        "totalGroundSojournTime"
        "meanGroundSojournTimeAcrossDays"
        "stdMeanGroundSojournTimeAcrossDays"
        "p95MeanGroundSojournTimeAcrossDays"
        "p99MeanGroundSojournTimeAcrossDays"
        "meanDailyP95GroundSojournTime"
        "p95DailyP95GroundSojournTime"
        "meanDailyP99GroundSojournTime"
        "maxDailyMaxGroundSojournTime"

        "totalDepartureDelay"
        "totalPositiveDepartureDelay"
        "meanPositiveDepartureDelayAcrossDays"
        "stdMeanPositiveDepartureDelayAcrossDays"
        "p90MeanPositiveDepartureDelayAcrossDays"
        "p95MeanPositiveDepartureDelayAcrossDays"
        "p99MeanPositiveDepartureDelayAcrossDays"
        "maxMeanPositiveDepartureDelayAcrossDays"
        "meanDailyP90PositiveDepartureDelay"
        "meanDailyP95PositiveDepartureDelay"
        "p95DailyP95PositiveDepartureDelay"
        "meanDailyP99PositiveDepartureDelay"
        "maxDailyMaxPositiveDepartureDelay"
        "totalDelayAboveD1"
        "totalDelayAboveD2"
        "totalDelayAboveD3"

        "totalDelayCost"
        "totalFluidCost"
        "totalActivationCost"
        "totalCancellationCost"
        "totalOperatingCost"
        "meanDailyOperatingCost"
        "stdDailyOperatingCost"
        "minDailyOperatingCost"
        "p90DailyOperatingCost"
        "p95DailyOperatingCost"
        "p99DailyOperatingCost"
        "maxDailyOperatingCost"
        "numPositiveCostDays"

        "numMissingOperatingCostDays"
        "numMissingVolumeDays"
        "numNonDepartedDays"
        "numUnresolvedDESDays"
        "numNonemptyTerminalCalendars"
    ];

    variableTypes = repmat("double", size(variableNames));

    stringColumns = [
        "modelType"
        "arrivalScenarioName"
        "serviceScenarioName"
        "taxiTakeoffScenarioName"
        "costScenarioName"
    ];

    variableTypes(ismember(variableNames, stringColumns)) = "string";

    resultsTable = table( ...
        'Size', [numRows, numel(variableNames)], ...
        'VariableTypes', cellstr(variableTypes(:)'), ...
        'VariableNames', cellstr(variableNames(:)'));
end

function rowTable = buildSimulationResultTableRow(modelResult, simulationPlan, modelType)
    rowTable = initializeResultsTable(1);

    rowTable.runIndex = NaN;
    rowTable.modelType = modelType;
    rowTable.numDays = getNestedNumeric(modelResult, ["numDays"]);

    rowTable.policyK = getNestedNumeric(simulationPlan, ["policy", "k"]);
    rowTable.policyE = getNestedNumeric(simulationPlan, ["policy", "e"]);

    rowTable.arrivalScenarioName = getNestedString(simulationPlan, ["arrivalProcess", "scenarioName"]);
    rowTable.serviceScenarioName = getNestedString(simulationPlan, ["serviceProcess", "scenarioName"]);
    rowTable.taxiTakeoffScenarioName = getNestedString(simulationPlan, ["taxiTakeoffProcess", "scenarioName"]);
    rowTable.costScenarioName = getNestedString(simulationPlan, ["costModel", "scenarioName"]);

    rowTable.annualNumberOfStorms = getNestedNumeric(simulationPlan, ["annualNumberOfStorms"]);

    rowTable.totalExternalArrivals = getNestedNumeric(modelResult, ["volume", "totalExternalArrivals"]);
    rowTable.totalDepartures = getNestedNumeric(modelResult, ["volume", "totalDepartures"]);
    rowTable.totalCancellations = getNestedNumeric(modelResult, ["cancellation", "totalCancellations"], ["volume", "totalCancellations"]);
    rowTable.totalDeicingJobs = getNestedNumeric(modelResult, ["volume", "totalDeicingJobs"]);
    rowTable.totalHOTViolations = getNestedNumeric(modelResult, ["volume", "totalHOTViolations"]);

    rowTable.meanExternalArrivalsPerDay = getNestedNumeric(modelResult, ["volume", "meanExternalArrivalsPerDay"]);
    rowTable.stdExternalArrivalsPerDay = getNestedNumeric(modelResult, ["volume", "stdExternalArrivalsPerDay"]);
    rowTable.p95ExternalArrivalsPerDay = getNestedNumeric(modelResult, ["volume", "p95ExternalArrivalsPerDay"]);
    rowTable.maxExternalArrivalsPerDay = getNestedNumeric(modelResult, ["volume", "maxExternalArrivalsPerDay"]);

    rowTable.meanDeparturesPerDay = getNestedNumeric(modelResult, ["status", "meanDeparturesPerDay"]);
    rowTable.meanCancellationsPerDay = getNestedNumeric(modelResult, ["cancellation", "meanCancellationsPerDay"], ["status", "meanCancellationsPerDay"]);
    rowTable.stdCancellationsPerDay = getNestedNumeric(modelResult, ["cancellation", "stdCancellationsPerDay"]);
    rowTable.p90CancellationsPerDay = getNestedNumeric(modelResult, ["cancellation", "p90CancellationsPerDay"]);
    rowTable.p95CancellationsPerDay = getNestedNumeric(modelResult, ["cancellation", "p95CancellationsPerDay"], ["status", "p95CancellationsPerDay"]);
    rowTable.p99CancellationsPerDay = getNestedNumeric(modelResult, ["cancellation", "p99CancellationsPerDay"]);
    rowTable.maxCancellationsPerDay = getNestedNumeric(modelResult, ["cancellation", "maxCancellationsPerDay"], ["status", "maxCancellationsPerDay"]);
    rowTable.numDaysWithCancellations = getNestedNumeric(modelResult, ["cancellation", "numDaysWithCancellations"], ["status", "numDaysWithCancellations"]);
    rowTable.cancellationRatePerExternalAircraft = getNestedNumeric(modelResult, ["cancellation", "cancellationRatePerExternalAircraft"]);
    rowTable.meanDailyCancellationRate = getNestedNumeric(modelResult, ["cancellation", "meanDailyCancellationRate"]);

    rowTable.meanDeicingJobsPerDay = getNestedNumeric(modelResult, ["volume", "meanDeicingJobsPerDay"]);
    rowTable.stdDeicingJobsPerDay = getNestedNumeric(modelResult, ["volume", "stdDeicingJobsPerDay"]);
    rowTable.p95DeicingJobsPerDay = getNestedNumeric(modelResult, ["volume", "p95DeicingJobsPerDay"]);
    rowTable.maxDeicingJobsPerDay = getNestedNumeric(modelResult, ["volume", "maxDeicingJobsPerDay"]);
    rowTable.meanHOTViolationsPerDay = getNestedNumeric(modelResult, ["volume", "meanHOTViolationsPerDay"]);
    rowTable.p95HOTViolationsPerDay = getNestedNumeric(modelResult, ["volume", "p95HOTViolationsPerDay"]);
    rowTable.maxHOTViolationsPerDay = getNestedNumeric(modelResult, ["volume", "maxHOTViolationsPerDay"]);
    rowTable.numDaysWithHOTViolations = getNestedNumeric(modelResult, ["volume", "numDaysWithHOTViolations"]);
    rowTable.meanDeicingJobsPerExternalAircraft = getNestedNumeric(modelResult, ["volume", "meanDeicingJobsPerExternalAircraft"]);
    rowTable.hotViolationRatePerExternalAircraft = getNestedNumeric(modelResult, ["volume", "hotViolationRatePerExternalAircraft"]);
    rowTable.hotViolationRatePerDeicingJob = getNestedNumeric(modelResult, ["volume", "hotViolationRatePerDeicingJob"]);

    rowTable.totalDeicingQueueingDelay = getNestedNumeric(modelResult, ["deicing", "totalQueueingDelay"]);
    rowTable.totalDeicingServiceTime = getNestedNumeric(modelResult, ["deicing", "totalServiceTime"]);
    rowTable.meanDeicingQueueingDelayAcrossDays = getNestedNumeric(modelResult, ["deicing", "meanQueueingDelayAcrossDays"]);
    rowTable.stdMeanDeicingQueueingDelayAcrossDays = getNestedNumeric(modelResult, ["deicing", "stdMeanQueueingDelayAcrossDays"]);
    rowTable.p95MeanDeicingQueueingDelayAcrossDays = getNestedNumeric(modelResult, ["deicing", "p95MeanQueueingDelayAcrossDays"]);
    rowTable.meanDeicingServiceTimeAcrossDays = getNestedNumeric(modelResult, ["deicing", "meanServiceTimeAcrossDays"]);
    rowTable.stdMeanDeicingServiceTimeAcrossDays = getNestedNumeric(modelResult, ["deicing", "stdMeanServiceTimeAcrossDays"]);
    rowTable.p95MeanDeicingServiceTimeAcrossDays = getNestedNumeric(modelResult, ["deicing", "p95MeanServiceTimeAcrossDays"]);
    rowTable.meanDailyP95DeicingQueueingDelay = getNestedNumeric(modelResult, ["deicing", "meanDailyP95QueueingDelay"]);
    rowTable.p95DailyP95DeicingQueueingDelay = getNestedNumeric(modelResult, ["deicing", "p95DailyP95QueueingDelay"]);
    rowTable.meanDailyP95DeicingServiceTime = getNestedNumeric(modelResult, ["deicing", "meanDailyP95ServiceTime"]);
    rowTable.p95DailyP95DeicingServiceTime = getNestedNumeric(modelResult, ["deicing", "p95DailyP95ServiceTime"]);

    rowTable.totalTaxiTakeoffQueueingDelay = getNestedNumeric(modelResult, ["taxiTakeoff", "totalQueueingDelay"]);
    rowTable.totalTaxiTakeoffServiceTime = getNestedNumeric(modelResult, ["taxiTakeoff", "totalServiceTime"]);
    rowTable.totalTaxiTakeoffSojournTime = getNestedNumeric(modelResult, ["taxiTakeoff", "totalSojournTime"]);
    rowTable.meanTaxiTakeoffQueueingDelayAcrossDays = getNestedNumeric(modelResult, ["taxiTakeoff", "meanQueueingDelayAcrossDays"]);
    rowTable.stdMeanTaxiTakeoffQueueingDelayAcrossDays = getNestedNumeric(modelResult, ["taxiTakeoff", "stdMeanQueueingDelayAcrossDays"]);
    rowTable.meanTaxiTakeoffServiceTimeAcrossDays = getNestedNumeric(modelResult, ["taxiTakeoff", "meanServiceTimeAcrossDays"]);
    rowTable.meanTaxiTakeoffSojournTimeAcrossDays = getNestedNumeric(modelResult, ["taxiTakeoff", "meanSojournTimeAcrossDays"]);
    rowTable.stdMeanTaxiTakeoffSojournTimeAcrossDays = getNestedNumeric(modelResult, ["taxiTakeoff", "stdMeanSojournTimeAcrossDays"]);
    rowTable.p95MeanTaxiTakeoffSojournTimeAcrossDays = getNestedNumeric(modelResult, ["taxiTakeoff", "p95MeanSojournTimeAcrossDays"]);
    rowTable.meanDailyP95TaxiTakeoffSojournTime = getNestedNumeric(modelResult, ["taxiTakeoff", "meanDailyP95SojournTime"]);
    rowTable.p95DailyP95TaxiTakeoffSojournTime = getNestedNumeric(modelResult, ["taxiTakeoff", "p95DailyP95SojournTime"]);

    rowTable.totalGroundSojournTime = getNestedNumeric(modelResult, ["groundSojourn", "totalGroundSojournTime"]);
    rowTable.meanGroundSojournTimeAcrossDays = getNestedNumeric(modelResult, ["groundSojourn", "meanGroundSojournTimeAcrossDays"]);
    rowTable.stdMeanGroundSojournTimeAcrossDays = getNestedNumeric(modelResult, ["groundSojourn", "stdMeanGroundSojournTimeAcrossDays"]);
    rowTable.p95MeanGroundSojournTimeAcrossDays = getNestedNumeric(modelResult, ["groundSojourn", "p95MeanGroundSojournTimeAcrossDays"]);
    rowTable.p99MeanGroundSojournTimeAcrossDays = getNestedNumeric(modelResult, ["groundSojourn", "p99MeanGroundSojournTimeAcrossDays"]);
    rowTable.meanDailyP95GroundSojournTime = getNestedNumeric(modelResult, ["groundSojourn", "meanDailyP95GroundSojournTime"]);
    rowTable.p95DailyP95GroundSojournTime = getNestedNumeric(modelResult, ["groundSojourn", "p95DailyP95GroundSojournTime"]);
    rowTable.meanDailyP99GroundSojournTime = getNestedNumeric(modelResult, ["groundSojourn", "meanDailyP99GroundSojournTime"]);
    rowTable.maxDailyMaxGroundSojournTime = getNestedNumeric(modelResult, ["groundSojourn", "maxDailyMaxGroundSojournTime"]);

    rowTable.totalDepartureDelay = getNestedNumeric(modelResult, ["departureDelay", "totalDepartureDelay"]);
    rowTable.totalPositiveDepartureDelay = getNestedNumeric(modelResult, ["departureDelay", "totalPositiveDepartureDelay"]);
    rowTable.meanPositiveDepartureDelayAcrossDays = getNestedNumeric(modelResult, ["departureDelay", "meanPositiveDepartureDelayAcrossDays"]);
    rowTable.stdMeanPositiveDepartureDelayAcrossDays = getNestedNumeric(modelResult, ["departureDelay", "stdMeanPositiveDepartureDelayAcrossDays"]);
    rowTable.p90MeanPositiveDepartureDelayAcrossDays = getNestedNumeric(modelResult, ["departureDelay", "p90MeanPositiveDepartureDelayAcrossDays"]);
    rowTable.p95MeanPositiveDepartureDelayAcrossDays = getNestedNumeric(modelResult, ["departureDelay", "p95MeanPositiveDepartureDelayAcrossDays"]);
    rowTable.p99MeanPositiveDepartureDelayAcrossDays = getNestedNumeric(modelResult, ["departureDelay", "p99MeanPositiveDepartureDelayAcrossDays"]);
    rowTable.maxMeanPositiveDepartureDelayAcrossDays = getNestedNumeric(modelResult, ["departureDelay", "maxMeanPositiveDepartureDelayAcrossDays"]);
    rowTable.meanDailyP90PositiveDepartureDelay = getNestedNumeric(modelResult, ["departureDelay", "meanDailyP90PositiveDepartureDelay"]);
    rowTable.meanDailyP95PositiveDepartureDelay = getNestedNumeric(modelResult, ["departureDelay", "meanDailyP95PositiveDepartureDelay"]);
    rowTable.p95DailyP95PositiveDepartureDelay = getNestedNumeric(modelResult, ["departureDelay", "p95DailyP95PositiveDepartureDelay"]);
    rowTable.meanDailyP99PositiveDepartureDelay = getNestedNumeric(modelResult, ["departureDelay", "meanDailyP99PositiveDepartureDelay"]);
    rowTable.maxDailyMaxPositiveDepartureDelay = getNestedNumeric(modelResult, ["departureDelay", "maxDailyMaxPositiveDepartureDelay"]);
    rowTable.totalDelayAboveD1 = getNestedNumeric(modelResult, ["departureDelay", "totalDelayAboveD1"]);
    rowTable.totalDelayAboveD2 = getNestedNumeric(modelResult, ["departureDelay", "totalDelayAboveD2"]);
    rowTable.totalDelayAboveD3 = getNestedNumeric(modelResult, ["departureDelay", "totalDelayAboveD3"]);

    rowTable.totalDelayCost = getNestedNumeric(modelResult, ["cost", "totalDelayCost"]);
    rowTable.totalFluidCost = getNestedNumeric(modelResult, ["cost", "totalFluidCost"]);
    rowTable.totalActivationCost = getNestedNumeric(modelResult, ["cost", "totalActivationCost"]);
    rowTable.totalCancellationCost = getNestedNumeric(modelResult, ["cost", "totalCancellationCost"], ["cancellation", "totalCancellationCost"]);
    rowTable.totalOperatingCost = getNestedNumeric(modelResult, ["cost", "totalOperatingCost"]);
    rowTable.meanDailyOperatingCost = getNestedNumeric(modelResult, ["cost", "meanDailyOperatingCost"]);
    rowTable.stdDailyOperatingCost = getNestedNumeric(modelResult, ["cost", "stdDailyOperatingCost"]);
    rowTable.minDailyOperatingCost = getNestedNumeric(modelResult, ["cost", "minDailyOperatingCost"]);
    rowTable.p90DailyOperatingCost = getNestedNumeric(modelResult, ["cost", "p90DailyOperatingCost"]);
    rowTable.p95DailyOperatingCost = getNestedNumeric(modelResult, ["cost", "p95DailyOperatingCost"]);
    rowTable.p99DailyOperatingCost = getNestedNumeric(modelResult, ["cost", "p99DailyOperatingCost"]);
    rowTable.maxDailyOperatingCost = getNestedNumeric(modelResult, ["cost", "maxDailyOperatingCost"]);
    rowTable.numPositiveCostDays = getNestedNumeric(modelResult, ["cost", "numPositiveCostDays"]);

    rowTable.numMissingOperatingCostDays = getNestedNumeric(modelResult, ["diagnostics", "numMissingOperatingCostDays"]);
    rowTable.numMissingVolumeDays = getNestedNumeric(modelResult, ["diagnostics", "numMissingVolumeDays"]);
    rowTable.numNonDepartedDays = getNestedNumeric(modelResult, ["diagnostics", "numNonDepartedDays"]);
    rowTable.numUnresolvedDESDays = getNestedNumeric(modelResult, ["diagnostics", "numUnresolvedDESDays"], ["diagnostics", "numIncompleteDESDays"]);
    rowTable.numNonemptyTerminalCalendars = getNestedNumeric(modelResult, ["diagnostics", "numNonemptyTerminalCalendars"]);
end

function value = getNestedNumeric(inputStruct, varargin)
    value = NaN;

    for idxPath = 1:numel(varargin)
        fieldPath = varargin{idxPath};
        [foundValue, rawValue] = tryGetNestedField(inputStruct, fieldPath);

        if foundValue && isnumeric(rawValue) && isscalar(rawValue)
            value = rawValue;
            return;
        end
    end
end

function value = getNestedString(inputStruct, fieldPath)
    [foundValue, rawValue] = tryGetNestedField(inputStruct, fieldPath);

    if foundValue && (isstring(rawValue) || ischar(rawValue))
        value = string(rawValue);
    else
        value = missing;
    end
end

function [foundValue, value] = tryGetNestedField(inputStruct, fieldPath)
    value = inputStruct;

    for idxField = 1:numel(fieldPath)
        currentField = char(fieldPath(idxField));

        if ~isstruct(value) || ~isfield(value, currentField)
            foundValue = false;
            value = [];
            return;
        end

        value = value.(currentField);
    end

    foundValue = true;
end

function projectRoot = findProjectRoot()
    currentDirectory = pwd;

    while true
        if isfolder(fullfile(currentDirectory, "src")) ...
                && (isfolder(fullfile(currentDirectory, "output")) ...
                    || isfolder(fullfile(currentDirectory, "outputs")))
            projectRoot = currentDirectory;
            return;
        end

        parentDirectory = fileparts(currentDirectory);

        if strcmp(parentDirectory, currentDirectory)
            error("writeSimulationResultsToCSV:ProjectRootNotFound", ...
                "Could not find project root containing src and output/outputs directory.");
        end

        currentDirectory = parentDirectory;
    end
end