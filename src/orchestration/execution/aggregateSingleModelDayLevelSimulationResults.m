function annualResults = aggregateDayLevelSimulationResults(dayLevelResults, simulationPlan)
    % AGGREGATEDAYLEVELSIMULATIONRESULTS Aggregates day-level simulation results.
    %
    % INPUT
    %  dayLevelResults struct array
    %      Array of day-level DES statistics or analytic approximations.
    %
    %  simulationPlan struct
    %      Full simulation plan attached for downstream CSV traceability.
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
        annualResults = buildEmptyAnnualResults(simulationPlan);
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

    % -- Deicing intensive quantities --
    meanDeicingQueueingDelay = extractNumericField(dayLevelResults, ...
        ["deicing", "meanQueueingDelayPerExternalAircraft"], ...
        ["deicing", "meanQueueingDelay"]);

    meanDeicingServiceTime = extractNumericField(dayLevelResults, ...
        ["deicing", "meanServiceTimePerExternalAircraft"], ...
        ["deicing", "meanServiceTime"]);

    % -- Deicing extensive quantities --
    totalDeicingQueueingDelay = extractNumericField(dayLevelResults, ...
        ["deicing", "totalQueueingDelay"]);

    totalDeicingServiceTime = extractNumericField(dayLevelResults, ...
        ["deicing", "totalServiceTime"]);

    analyticQueueingMask = isnan(totalDeicingQueueingDelay) ...
        & ~isnan(totalDeicingJobs) ...
        & ~isnan(meanDeicingQueueingDelay);

    analyticServiceMask = isnan(totalDeicingServiceTime) ...
        & ~isnan(totalDeicingJobs) ...
        & ~isnan(meanDeicingServiceTime);

    totalDeicingQueueingDelay(analyticQueueingMask) = ...
        totalDeicingJobs(analyticQueueingMask) ...
        .* meanDeicingQueueingDelay(analyticQueueingMask);

    totalDeicingServiceTime(analyticServiceMask) = ...
        totalDeicingJobs(analyticServiceMask) ...
        .* meanDeicingServiceTime(analyticServiceMask);

    p95DeicingQueueingDelay = extractNumericField(dayLevelResults, ...
        ["deicing", "p95QueueingDelay"]);

    p95DeicingServiceTime = extractNumericField(dayLevelResults, ...
        ["deicing", "p95ServiceTime"]);

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

    p95TaxiTakeoffSojournTime = extractNumericField(dayLevelResults, ...
        ["taxiTakeoff", "p95SojournTime"]);

    % -- Ground sojourn --
    totalGroundSojournTime = extractNumericField(dayLevelResults, ...
        ["groundSojourn", "totalGroundSojournTime"]);

    meanGroundSojournTime = extractNumericField(dayLevelResults, ...
        ["groundSojourn", "meanGroundSojournTime"]);

    p95GroundSojournTime = extractNumericField(dayLevelResults, ...
        ["groundSojourn", "p95GroundSojournTime"]);

    p99GroundSojournTime = extractNumericField(dayLevelResults, ...
        ["groundSojourn", "p99GroundSojournTime"]);

    maxGroundSojournTime = extractNumericField(dayLevelResults, ...
        ["groundSojourn", "maxGroundSojournTime"]);

    % -- Departure delay --
    totalDepartureDelay = extractNumericField(dayLevelResults, ...
        ["departureDelay", "totalDepartureDelay"]);

    totalPositiveDepartureDelay = extractNumericField(dayLevelResults, ...
        ["departureDelay", "totalPositiveDepartureDelay"]);

    meanPositiveDepartureDelay = extractNumericField(dayLevelResults, ...
        ["departureDelay", "meanPositiveDepartureDelay"], ...
        ["departureDelay", "meanPositiveDelayProxy"]);

    analyticDelayTotalMask = isnan(totalPositiveDepartureDelay) ...
        & ~isnan(numExternalArrivals) ...
        & ~isnan(meanPositiveDepartureDelay);

    totalPositiveDepartureDelay(analyticDelayTotalMask) = ...
        numExternalArrivals(analyticDelayTotalMask) ...
        .* meanPositiveDepartureDelay(analyticDelayTotalMask);

    p90PositiveDepartureDelay = extractNumericField(dayLevelResults, ...
        ["departureDelay", "p90PositiveDepartureDelay"]);

    p95PositiveDepartureDelay = extractNumericField(dayLevelResults, ...
        ["departureDelay", "p95PositiveDepartureDelay"]);

    p99PositiveDepartureDelay = extractNumericField(dayLevelResults, ...
        ["departureDelay", "p99PositiveDepartureDelay"]);

    maxPositiveDepartureDelay = extractNumericField(dayLevelResults, ...
        ["departureDelay", "maxPositiveDepartureDelay"]);

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

    % -- Diagnostics --
    allAircraftDeparted = extractLogicalField(dayLevelResults, ...
        ["diagnostics", "allAircraftDeparted"]);

    finalEventCalendarEmpty = extractLogicalField(dayLevelResults, ...
        ["diagnostics", "finalEventCalendarEmpty"]);

    % -- Build annual result --
    annualResults = struct();

    annualResults.numDays = numDays;

    annualResults = buildTemplateSimulationResultStruct();

    annualResults.numDays = numDays;
    annualResults.policy = simulationPlan.policy;

    annualResults.volume = struct();
    annualResults.volume.totalExternalArrivals = sumIgnoringNaN(numExternalArrivals);
    annualResults.volume.totalDeicingJobs = sumIgnoringNaN(totalDeicingJobs);
    annualResults.volume.totalHOTViolations = sumIgnoringNaN(numHOTViolations);

    annualResults.volume.meanExternalArrivalsPerDay = meanIgnoringNaN(numExternalArrivals);
    annualResults.volume.stdExternalArrivalsPerDay = stdIgnoringNaN(numExternalArrivals);
    annualResults.volume.p95ExternalArrivalsPerDay = percentileIgnoringNaN(numExternalArrivals, 95);
    annualResults.volume.maxExternalArrivalsPerDay = maxIgnoringNaN(numExternalArrivals);

    annualResults.volume.meanDeicingJobsPerDay = meanIgnoringNaN(totalDeicingJobs);
    annualResults.volume.stdDeicingJobsPerDay = stdIgnoringNaN(totalDeicingJobs);
    annualResults.volume.p95DeicingJobsPerDay = percentileIgnoringNaN(totalDeicingJobs, 95);
    annualResults.volume.maxDeicingJobsPerDay = maxIgnoringNaN(totalDeicingJobs);

    annualResults.volume.meanHOTViolationsPerDay = meanIgnoringNaN(numHOTViolations);
    annualResults.volume.p95HOTViolationsPerDay = percentileIgnoringNaN(numHOTViolations, 95);
    annualResults.volume.maxHOTViolationsPerDay = maxIgnoringNaN(numHOTViolations);
    annualResults.volume.numDaysWithHOTViolations = sumLogicalCondition(numHOTViolations > 0);

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
    annualResults.deicing.stdMeanQueueingDelayAcrossDays = stdIgnoringNaN(meanDeicingQueueingDelay);
    annualResults.deicing.p95MeanQueueingDelayAcrossDays = percentileIgnoringNaN(meanDeicingQueueingDelay, 95);
    annualResults.deicing.meanServiceTimeAcrossDays = meanIgnoringNaN(meanDeicingServiceTime);
    annualResults.deicing.stdMeanServiceTimeAcrossDays = stdIgnoringNaN(meanDeicingServiceTime);
    annualResults.deicing.p95MeanServiceTimeAcrossDays = percentileIgnoringNaN(meanDeicingServiceTime, 95);
    annualResults.deicing.meanDailyP95QueueingDelay = meanIgnoringNaN(p95DeicingQueueingDelay);
    annualResults.deicing.p95DailyP95QueueingDelay = percentileIgnoringNaN(p95DeicingQueueingDelay, 95);
    annualResults.deicing.meanDailyP95ServiceTime = meanIgnoringNaN(p95DeicingServiceTime);
    annualResults.deicing.p95DailyP95ServiceTime = percentileIgnoringNaN(p95DeicingServiceTime, 95);

    annualResults.taxiTakeoff = struct();
    annualResults.taxiTakeoff.totalQueueingDelay = sumIgnoringNaN(totalTaxiTakeoffQueueingDelay);
    annualResults.taxiTakeoff.totalServiceTime = sumIgnoringNaN(totalTaxiTakeoffServiceTime);
    annualResults.taxiTakeoff.totalSojournTime = sumIgnoringNaN(totalTaxiTakeoffSojournTime);
    annualResults.taxiTakeoff.meanQueueingDelayAcrossDays = meanIgnoringNaN(meanTaxiTakeoffQueueingDelay);
    annualResults.taxiTakeoff.stdMeanQueueingDelayAcrossDays = stdIgnoringNaN(meanTaxiTakeoffQueueingDelay);
    annualResults.taxiTakeoff.meanServiceTimeAcrossDays = meanIgnoringNaN(meanTaxiTakeoffServiceTime);
    annualResults.taxiTakeoff.meanSojournTimeAcrossDays = meanIgnoringNaN(meanTaxiTakeoffSojournTime);
    annualResults.taxiTakeoff.stdMeanSojournTimeAcrossDays = stdIgnoringNaN(meanTaxiTakeoffSojournTime);
    annualResults.taxiTakeoff.p95MeanSojournTimeAcrossDays = percentileIgnoringNaN(meanTaxiTakeoffSojournTime, 95);
    annualResults.taxiTakeoff.meanDailyP95SojournTime = meanIgnoringNaN(p95TaxiTakeoffSojournTime);
    annualResults.taxiTakeoff.p95DailyP95SojournTime = percentileIgnoringNaN(p95TaxiTakeoffSojournTime, 95);

    annualResults.groundSojourn = struct();
    annualResults.groundSojourn.totalGroundSojournTime = sumIgnoringNaN(totalGroundSojournTime);
    annualResults.groundSojourn.meanGroundSojournTimeAcrossDays = meanIgnoringNaN(meanGroundSojournTime);
    annualResults.groundSojourn.stdMeanGroundSojournTimeAcrossDays = stdIgnoringNaN(meanGroundSojournTime);
    annualResults.groundSojourn.p95MeanGroundSojournTimeAcrossDays = percentileIgnoringNaN(meanGroundSojournTime, 95);
    annualResults.groundSojourn.p99MeanGroundSojournTimeAcrossDays = percentileIgnoringNaN(meanGroundSojournTime, 99);
    annualResults.groundSojourn.meanDailyP95GroundSojournTime = meanIgnoringNaN(p95GroundSojournTime);
    annualResults.groundSojourn.p95DailyP95GroundSojournTime = percentileIgnoringNaN(p95GroundSojournTime, 95);
    annualResults.groundSojourn.meanDailyP99GroundSojournTime = meanIgnoringNaN(p99GroundSojournTime);
    annualResults.groundSojourn.maxDailyMaxGroundSojournTime = maxIgnoringNaN(maxGroundSojournTime);

    annualResults.departureDelay = struct();
    annualResults.departureDelay.totalDepartureDelay = sumIgnoringNaN(totalDepartureDelay);
    annualResults.departureDelay.totalPositiveDepartureDelay = sumIgnoringNaN(totalPositiveDepartureDelay);
    annualResults.departureDelay.meanPositiveDepartureDelayAcrossDays = meanIgnoringNaN(meanPositiveDepartureDelay);
    annualResults.departureDelay.stdMeanPositiveDepartureDelayAcrossDays = stdIgnoringNaN(meanPositiveDepartureDelay);
    annualResults.departureDelay.p90MeanPositiveDepartureDelayAcrossDays = percentileIgnoringNaN(meanPositiveDepartureDelay, 90);
    annualResults.departureDelay.p95MeanPositiveDepartureDelayAcrossDays = percentileIgnoringNaN(meanPositiveDepartureDelay, 95);
    annualResults.departureDelay.p99MeanPositiveDepartureDelayAcrossDays = percentileIgnoringNaN(meanPositiveDepartureDelay, 99);
    annualResults.departureDelay.maxMeanPositiveDepartureDelayAcrossDays = maxIgnoringNaN(meanPositiveDepartureDelay);

    annualResults.departureDelay.meanDailyP90PositiveDepartureDelay = meanIgnoringNaN(p90PositiveDepartureDelay);
    annualResults.departureDelay.meanDailyP95PositiveDepartureDelay = meanIgnoringNaN(p95PositiveDepartureDelay);
    annualResults.departureDelay.p95DailyP95PositiveDepartureDelay = percentileIgnoringNaN(p95PositiveDepartureDelay, 95);
    annualResults.departureDelay.meanDailyP99PositiveDepartureDelay = meanIgnoringNaN(p99PositiveDepartureDelay);
    annualResults.departureDelay.maxDailyMaxPositiveDepartureDelay = maxIgnoringNaN(maxPositiveDepartureDelay);

    annualResults.departureDelay.totalDelayAboveD1 = sumIgnoringNaN(totalDelayAboveD1);
    annualResults.departureDelay.totalDelayAboveD2 = sumIgnoringNaN(totalDelayAboveD2);
    annualResults.departureDelay.totalDelayAboveD3 = sumIgnoringNaN(totalDelayAboveD3);

    annualResults.cost = struct();
    annualResults.cost.totalDelayCost = sumIgnoringNaN(delayCost);
    annualResults.cost.totalFluidCost = sumIgnoringNaN(fluidCost);
    annualResults.cost.totalActivationCost = sumIgnoringNaN(activationCost);
    annualResults.cost.totalOperatingCost = sumIgnoringNaN(totalOperatingCost);
    annualResults.cost.meanDailyOperatingCost = meanIgnoringNaN(totalOperatingCost);
    annualResults.cost.stdDailyOperatingCost = stdIgnoringNaN(totalOperatingCost);
    annualResults.cost.minDailyOperatingCost = minIgnoringNaN(totalOperatingCost);
    annualResults.cost.p90DailyOperatingCost = percentileIgnoringNaN(totalOperatingCost, 90);
    annualResults.cost.p95DailyOperatingCost = percentileIgnoringNaN(totalOperatingCost, 95);
    annualResults.cost.p99DailyOperatingCost = percentileIgnoringNaN(totalOperatingCost, 99);
    annualResults.cost.maxDailyOperatingCost = maxIgnoringNaN(totalOperatingCost);
    annualResults.cost.numPositiveCostDays = sumLogicalCondition(totalOperatingCost > 0);

    annualResults.diagnostics = struct();
    annualResults.diagnostics.numMissingOperatingCostDays = sum(isnan(totalOperatingCost));
    annualResults.diagnostics.numMissingVolumeDays = sum(isnan(numExternalArrivals));
    annualResults.diagnostics.numIncompleteDESDays = sumLogicalCondition(allAircraftDeparted == 0);
    annualResults.diagnostics.numNonemptyTerminalCalendars = sumLogicalCondition(finalEventCalendarEmpty == 0);

    annualResults.simulationPlan = simulationPlan;
end

function values = extractNumericField(dayLevelResults, varargin)
    numDays = numel(dayLevelResults);
    values = NaN(numDays, 1);

    for idxDay = 1:numDays
        for idxPath = 1:numel(varargin)
            currentPath = varargin{idxPath};

            [foundValue, value] = tryGetNestedNumericField( ...
                dayLevelResults(idxDay), currentPath);

            if foundValue
                values(idxDay) = value;
                break;
            end
        end
    end
end

function values = extractLogicalField(dayLevelResults, fieldPath)
    numDays = numel(dayLevelResults);
    values = NaN(numDays, 1);

    for idxDay = 1:numDays
        [foundValue, value] = tryGetNestedAnyField(dayLevelResults(idxDay), fieldPath);

        if foundValue && (islogical(value) || isnumeric(value)) && isscalar(value)
            values(idxDay) = double(value);
        end
    end
end

function [foundValue, value] = tryGetNestedNumericField(inputStruct, fieldPath)
    [foundValue, value] = tryGetNestedAnyField(inputStruct, fieldPath);

    if ~foundValue
        value = NaN;
        return;
    end

    if ~(isnumeric(value) && isscalar(value))
        foundValue = false;
        value = NaN;
    end
end

function [foundValue, value] = tryGetNestedAnyField(inputStruct, fieldPath)
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

    foundValue = true;
    value = currentValue;
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

function standardDeviation = stdIgnoringNaN(values)
    validMask = ~isnan(values);

    if ~any(validMask)
        standardDeviation = NaN;
    else
        standardDeviation = std(values(validMask));
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

function minimum = minIgnoringNaN(values)
    validMask = ~isnan(values);

    if ~any(validMask)
        minimum = NaN;
    else
        minimum = min(values(validMask));
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

function count = sumLogicalCondition(logicalValues)
    validMask = ~isnan(double(logicalValues));
    count = sum(logicalValues(validMask));
end

function quotient = safeDivide(numerator, denominator)
    if denominator == 0 || isnan(denominator)
        quotient = NaN;
    else
        quotient = numerator / denominator;
    end
end

function annualResults = buildEmptyAnnualResults(simulationPlan)
    annualResults = struct();
    annualResults.numDays = 0;
    annualResults.volume = struct();
    annualResults.deicing = struct();
    annualResults.taxiTakeoff = struct();
    annualResults.groundSojourn = struct();
    annualResults.departureDelay = struct();
    annualResults.cost = struct();
    annualResults.diagnostics = struct();
    annualResults.simulationPlan = simulationPlan;
end