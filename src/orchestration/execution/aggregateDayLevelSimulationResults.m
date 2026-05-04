function annualResults = aggregateDayLevelSimulationResults(dayLevelResults, simulationPlan)
    % AGGREGATEDAYLEVELSIMULATIONRESULTS Aggregates day-level simulation results.
    %
    % INPUT
    %  dayLevelResults struct array
    %      Array of day-level DES statistics or analytic approximations.
    %
    % OUTPUT
    %  annualResults struct
    %      Annual aggregate results computed by summing extensive quantities
    %      and averaging / percentile-aggregating intensive day-level quantities.

    arguments
        dayLevelResults (:, 1) struct
        simulationPlan (1, 1) struct
    end

    if isempty(dayLevelResults)
        annualResults = buildEmptyAnnualResults();
        return;
    end

    numDays = numel(dayLevelResults);

    % -- Volume --
    numExternalArrivals = extractNumericField(dayLevelResults, ...
        ["volume", "numExternalArrivals"], ...
        ["volume", "expectedExternalArrivals"]);

    totalDeicingJobs = extractNumericField(dayLevelResults, ...
        ["volume", "totalDeicingJobs"], ...
        ["volume", "expectedDeicingJobs"]);

    numHOTViolations = extractNumericField(dayLevelResults, ...
        ["volume", "numHOTViolations"], ...
        ["volume", "expectedHOTViolations"]);

    % -- Deicing --
    totalDeicingQueueingDelay = extractNumericField(dayLevelResults, ...
        ["deicing", "totalQueueingDelay"], ...
        ["deicing", "meanQueueingDelay"]);

    totalDeicingServiceTime = extractNumericField(dayLevelResults, ...
        ["deicing", "totalServiceTime"], ...
        ["deicing", "meanServiceTime"]);

    meanDeicingQueueingDelay = extractNumericField(dayLevelResults, ...
        ["deicing", "meanQueueingDelayPerExternalAircraft"], ...
        ["deicing", "meanQueueingDelay"]);

    meanDeicingServiceTime = extractNumericField(dayLevelResults, ...
        ["deicing", "meanServiceTimePerExternalAircraft"], ...
        ["deicing", "meanServiceTime"]);

    % -- Taxi / takeoff --
    totalTaxiTakeoffQueueingDelay = extractNumericField(dayLevelResults, ...
        ["taxiTakeoff", "totalQueueingDelay"]);

    totalTaxiTakeoffServiceTime = extractNumericField(dayLevelResults, ...
        ["taxiTakeoff", "totalServiceTime"]);

    totalTaxiTakeoffSojournTime = extractNumericField(dayLevelResults, ...
        ["taxiTakeoff", "totalSojournTime"]);

    meanTaxiTakeoffQueueingDelay = extractNumericField(dayLevelResults, ...
        ["taxiTakeoff", "meanQueueingDelayPerExternalAircraft"]);

    meanTaxiTakeoffServiceTime = extractNumericField(dayLevelResults, ...
        ["taxiTakeoff", "meanServiceTimePerExternalAircraft"]);

    meanTaxiTakeoffSojournTime = extractNumericField(dayLevelResults, ...
        ["taxiTakeoff", "meanSojournTimePerExternalAircraft"], ...
        ["taxiTakeoff", "meanSojournTime"]);

    % -- Ground sojourn --
    totalGroundSojournTime = extractNumericField(dayLevelResults, ...
        ["groundSojourn", "totalGroundSojournTime"]);

    meanGroundSojournTime = extractNumericField(dayLevelResults, ...
        ["groundSojourn", "meanGroundSojournTime"]);

    p95GroundSojournTime = extractNumericField(dayLevelResults, ...
        ["groundSojourn", "p95GroundSojournTime"]);

    % -- Departure delay --
    totalDepartureDelay = extractNumericField(dayLevelResults, ...
        ["departureDelay", "totalDepartureDelay"]);

    totalPositiveDepartureDelay = extractNumericField(dayLevelResults, ...
        ["departureDelay", "totalPositiveDepartureDelay"], ...
        ["departureDelay", "meanPositiveDelayProxy"]);

    meanPositiveDepartureDelay = extractNumericField(dayLevelResults, ...
        ["departureDelay", "meanPositiveDepartureDelay"], ...
        ["departureDelay", "meanPositiveDelayProxy"]);

    totalDelayAboveD1 = extractNumericField(dayLevelResults, ...
        ["departureDelay", "totalDelayAboveD1"]);

    totalDelayAboveD2 = extractNumericField(dayLevelResults, ...
        ["departureDelay", "totalDelayAboveD2"]);

    totalDelayAboveD3 = extractNumericField(dayLevelResults, ...
        ["departureDelay", "totalDelayAboveD3"]);

    % -- Cost --
    delayCost = extractNumericField(dayLevelResults, ["cost", "delayCost"]);
    fluidCost = extractNumericField(dayLevelResults, ["cost", "fluidCost"]);
    activationCost = extractNumericField(dayLevelResults, ["cost", "activationCost"]);
    totalOperatingCost = extractNumericField(dayLevelResults, ["cost", "totalOperatingCost"]);

    % -- Build annual result --
    annualResults = struct();

    annualResults.numDays = numDays;

    if isfield(dayLevelResults(1), "policy")
        annualResults.policy = dayLevelResults(1).policy;
    end

    annualResults.volume = struct();
    annualResults.volume.totalExternalArrivals = sumIgnoringNaN(numExternalArrivals);
    annualResults.volume.totalDeicingJobs = sumIgnoringNaN(totalDeicingJobs);
    annualResults.volume.totalHOTViolations = sumIgnoringNaN(numHOTViolations);
    annualResults.volume.meanExternalArrivalsPerDay = meanIgnoringNaN(numExternalArrivals);
    annualResults.volume.meanDeicingJobsPerDay = meanIgnoringNaN(totalDeicingJobs);
    annualResults.volume.meanHOTViolationsPerDay = meanIgnoringNaN(numHOTViolations);
    annualResults.volume.meanDeicingJobsPerExternalAircraft = safeDivide( ...
        annualResults.volume.totalDeicingJobs, ...
        annualResults.volume.totalExternalArrivals);
    annualResults.volume.hotViolationRatePerExternalAircraft = safeDivide( ...
        annualResults.volume.totalHOTViolations, ...
        annualResults.volume.totalExternalArrivals);
    annualResults.volume.hotViolationRatePerDeicingJob = safeDivide( ...
        annualResults.volume.totalHOTViolations, ...
        annualResults.volume.totalDeicingJobs);

    annualResults.deicing = struct();
    annualResults.deicing.totalQueueingDelay = sumIgnoringNaN(totalDeicingQueueingDelay);
    annualResults.deicing.totalServiceTime = sumIgnoringNaN(totalDeicingServiceTime);
    annualResults.deicing.meanQueueingDelayAcrossDays = meanIgnoringNaN(meanDeicingQueueingDelay);
    annualResults.deicing.meanServiceTimeAcrossDays = meanIgnoringNaN(meanDeicingServiceTime);
    annualResults.deicing.p95MeanQueueingDelayAcrossDays = percentileIgnoringNaN(meanDeicingQueueingDelay, 95);
    annualResults.deicing.p95MeanServiceTimeAcrossDays = percentileIgnoringNaN(meanDeicingServiceTime, 95);

    annualResults.taxiTakeoff = struct();
    annualResults.taxiTakeoff.totalQueueingDelay = sumIgnoringNaN(totalTaxiTakeoffQueueingDelay);
    annualResults.taxiTakeoff.totalServiceTime = sumIgnoringNaN(totalTaxiTakeoffServiceTime);
    annualResults.taxiTakeoff.totalSojournTime = sumIgnoringNaN(totalTaxiTakeoffSojournTime);
    annualResults.taxiTakeoff.meanQueueingDelayAcrossDays = meanIgnoringNaN(meanTaxiTakeoffQueueingDelay);
    annualResults.taxiTakeoff.meanServiceTimeAcrossDays = meanIgnoringNaN(meanTaxiTakeoffServiceTime);
    annualResults.taxiTakeoff.meanSojournTimeAcrossDays = meanIgnoringNaN(meanTaxiTakeoffSojournTime);
    annualResults.taxiTakeoff.p95MeanSojournTimeAcrossDays = percentileIgnoringNaN(meanTaxiTakeoffSojournTime, 95);

    annualResults.groundSojourn = struct();
    annualResults.groundSojourn.totalGroundSojournTime = sumIgnoringNaN(totalGroundSojournTime);
    annualResults.groundSojourn.meanGroundSojournTimeAcrossDays = meanIgnoringNaN(meanGroundSojournTime);
    annualResults.groundSojourn.p95MeanGroundSojournTimeAcrossDays = percentileIgnoringNaN(meanGroundSojournTime, 95);
    annualResults.groundSojourn.p95DailyP95GroundSojournTime = percentileIgnoringNaN(p95GroundSojournTime, 95);

    annualResults.departureDelay = struct();
    annualResults.departureDelay.totalDepartureDelay = sumIgnoringNaN(totalDepartureDelay);
    annualResults.departureDelay.totalPositiveDepartureDelay = sumIgnoringNaN(totalPositiveDepartureDelay);
    annualResults.departureDelay.meanPositiveDepartureDelayAcrossDays = meanIgnoringNaN(meanPositiveDepartureDelay);
    annualResults.departureDelay.p95MeanPositiveDepartureDelayAcrossDays = percentileIgnoringNaN(meanPositiveDepartureDelay, 95);
    annualResults.departureDelay.totalDelayAboveD1 = sumIgnoringNaN(totalDelayAboveD1);
    annualResults.departureDelay.totalDelayAboveD2 = sumIgnoringNaN(totalDelayAboveD2);
    annualResults.departureDelay.totalDelayAboveD3 = sumIgnoringNaN(totalDelayAboveD3);

    annualResults.cost = struct();
    annualResults.cost.totalDelayCost = sumIgnoringNaN(delayCost);
    annualResults.cost.totalFluidCost = sumIgnoringNaN(fluidCost);
    annualResults.cost.totalActivationCost = sumIgnoringNaN(activationCost);
    annualResults.cost.totalOperatingCost = sumIgnoringNaN(totalOperatingCost);
    annualResults.cost.meanDailyOperatingCost = meanIgnoringNaN(totalOperatingCost);
    annualResults.cost.p95DailyOperatingCost = percentileIgnoringNaN(totalOperatingCost, 95);
    annualResults.cost.maxDailyOperatingCost = maxIgnoringNaN(totalOperatingCost);

    annualResults.diagnostics = struct();
    annualResults.diagnostics.numMissingOperatingCostDays = sum(isnan(totalOperatingCost));
    annualResults.diagnostics.numMissingVolumeDays = sum(isnan(numExternalArrivals));

    annualResults.simulationPlan = simulationPlan;
end

function values = extractNumericField(dayLevelResults, varargin)
    numDays = numel(dayLevelResults);
    values = NaN(numDays, 1);

    for idxDay = 1:numDays
        for idxPath = 1:numel(varargin)
            currentPath = varargin{idxPath};

            [foundValue, value] = tryGetNestedField(dayLevelResults(idxDay), currentPath);

            if foundValue
                values(idxDay) = value;
                break;
            end
        end
    end
end

function [foundValue, value] = tryGetNestedField(inputStruct, fieldPath)
    currentValue = inputStruct;

    for idxField = 1:numel(fieldPath)
        currentField = char(fieldPath(idxField));

        if ~isstruct(currentValue) || ~isfield(currentValue, currentField)
            foundValue = false;
            value = NaN;
            return;
        end

        currentValue = currentValue.(currentField);
    end

    if isnumeric(currentValue) && isscalar(currentValue)
        foundValue = true;
        value = currentValue;
    else
        foundValue = false;
        value = NaN;
    end
end

function total = sumIgnoringNaN(values)
    validMask = ~isnan(values);
    total = sum(values(validMask));
end

function average = meanIgnoringNaN(values)
    validMask = ~isnan(values);

    if ~any(validMask)
        average = NaN;
    else
        average = mean(values(validMask));
    end
end

function percentileValue = percentileIgnoringNaN(values, percentile)
    validMask = ~isnan(values);

    if ~any(validMask)
        percentileValue = NaN;
    else
        percentileValue = prctile(values(validMask), percentile);
    end
end

function maximum = maxIgnoringNaN(values)
    validMask = ~isnan(values);

    if ~any(validMask)
        maximum = NaN;
    else
        maximum = max(values(validMask));
    end
end

function quotient = safeDivide(numerator, denominator)
    if denominator == 0 || isnan(denominator)
        quotient = NaN;
    else
        quotient = numerator / denominator;
    end
end

function annualResults = buildEmptyAnnualResults()
    annualResults = struct();
    annualResults.numDays = 0;
    annualResults.volume = struct();
    annualResults.deicing = struct();
    annualResults.taxiTakeoff = struct();
    annualResults.groundSojourn = struct();
    annualResults.departureDelay = struct();
    annualResults.cost = struct();
    annualResults.diagnostics = struct();
end