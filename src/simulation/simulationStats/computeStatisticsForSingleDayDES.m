function singleDayStats = computeStatisticsForSingleDayDES(simContext, delayCostThresholds, costModel)
    % COMPUTESTATISTICSFORSINGLEDAYDES Computes results of single-day DES via Monte Carlo estimation.

    arguments
        simContext (1, 1) struct
        delayCostThresholds (1, 3) double {mustBeNonnegative, mustBeFinite}
        costModel (1, 1) struct
    end

    aircraft = simContext.state.aircraft;

    if isempty(aircraft)
        singleDayStats = buildEmptySingleDayStats();
        return;
    end

    % -- Aircraft status masks --
    aircraftLocations = string({aircraft.currentLocation});
    departedMask = aircraftLocations == "departed";

    if isfield(aircraft, "isCancelled")
        cancelledMask = logical([aircraft.isCancelled]);
    else
        cancelledMask = aircraftLocations == "cancelled";
    end

    activeOrUnresolvedMask = ~(departedMask | cancelledMask);

    % -- Extract aircraft-level vectors --
    aircraftTypes = string({aircraft.type});
    initialArrivalTimes = [aircraft.initialArrivalTime];
    actualTakeoffTimes = [aircraft.actualTakeoffTime];
    scheduledTakeoffTimes = [aircraft.STD];

    numDeicingCycles = [aircraft.numDeicingCyclesCompleted];
    deicingQueueingDelays = [aircraft.totalDeicingQueueingDelay];
    deicingServiceTimes = [aircraft.totalDeicingServiceTime];
    taxiTakeoffQueueingDelays = [aircraft.totalTaxiTakeoffQueueingDelay];
    taxiTakeoffServiceTimes = [aircraft.totalTaxiTakeoffServiceTime];

    if isfield(aircraft, "numHOTViolations")
        numHOTViolationsByAircraft = [aircraft.numHOTViolations];
    else
        numHOTViolationsByAircraft = max(numDeicingCycles - 1, 0);
    end

    % -- Departed-only vectors --
    departedInitialArrivalTimes = initialArrivalTimes(departedMask);
    departedActualTakeoffTimes = actualTakeoffTimes(departedMask);
    departedScheduledTakeoffTimes = scheduledTakeoffTimes(departedMask);

    groundSojournTimes = departedActualTakeoffTimes - departedInitialArrivalTimes;
    departureDelays = departedActualTakeoffTimes - departedScheduledTakeoffTimes;
    positiveDepartureDelays = max(departureDelays, 0);

    taxiTakeoffSojournTimes = taxiTakeoffQueueingDelays + taxiTakeoffServiceTimes;

    numExternalArrivals = numel(aircraft);
    numDepartures = sum(departedMask);
    numCancellations = sum(cancelledMask);
    numUnresolvedAircraft = sum(activeOrUnresolvedMask);

    totalDeicingJobs = sum(numDeicingCycles);
    numHOTViolations = sum(numHOTViolationsByAircraft);

    % -- Populate output struct --
    singleDayStats = struct();

    singleDayStats.policy = simContext.policy;
    singleDayStats.storm = simContext.storm;

    singleDayStats.status = struct();
    singleDayStats.status.numDepartures = numDepartures;
    singleDayStats.status.numCancellations = numCancellations;
    singleDayStats.status.numUnresolvedAircraft = numUnresolvedAircraft;
    singleDayStats.status.departureRate = safeDivide(numDepartures, numExternalArrivals);
    singleDayStats.status.cancellationRate = safeDivide(numCancellations, numExternalArrivals);
    singleDayStats.status.unresolvedRate = safeDivide(numUnresolvedAircraft, numExternalArrivals);

    singleDayStats.volume = struct();
    singleDayStats.volume.numExternalArrivals = numExternalArrivals;
    singleDayStats.volume.numDepartures = numDepartures;
    singleDayStats.volume.numCancellations = numCancellations;
    singleDayStats.volume.totalDeicingJobs = totalDeicingJobs;
    singleDayStats.volume.meanDeicingJobsPerExternalAircraft = ...
        safeDivide(totalDeicingJobs, numExternalArrivals);
    singleDayStats.volume.numHOTViolations = numHOTViolations;
    singleDayStats.volume.hotViolationRatePerExternalAircraft = ...
        safeDivide(numHOTViolations, numExternalArrivals);
    singleDayStats.volume.hotViolationRatePerDeicingJob = ...
        safeDivide(numHOTViolations, totalDeicingJobs);

    singleDayStats.cancellation = struct();
    singleDayStats.cancellation.numCancellations = numCancellations;
    singleDayStats.cancellation.cancellationRate = ...
        safeDivide(numCancellations, numExternalArrivals);
    singleDayStats.cancellation.totalCancellationCost = ...
        numCancellations * costModel.cancellationCost;

    singleDayStats.deicing = struct();
    singleDayStats.deicing.totalQueueingDelay = sum(deicingQueueingDelays, "omitnan");
    singleDayStats.deicing.totalServiceTime = sum(deicingServiceTimes, "omitnan");
    singleDayStats.deicing.meanQueueingDelayPerExternalAircraft = ...
        mean(deicingQueueingDelays, "omitnan");
    singleDayStats.deicing.meanServiceTimePerExternalAircraft = ...
        mean(deicingServiceTimes, "omitnan");
    singleDayStats.deicing.p95QueueingDelay = safePrctile(deicingQueueingDelays, 95);
    singleDayStats.deicing.p95ServiceTime = safePrctile(deicingServiceTimes, 95);

    singleDayStats.taxiTakeoff = struct();
    singleDayStats.taxiTakeoff.totalQueueingDelay = sum(taxiTakeoffQueueingDelays, "omitnan");
    singleDayStats.taxiTakeoff.totalServiceTime = sum(taxiTakeoffServiceTimes, "omitnan");
    singleDayStats.taxiTakeoff.totalSojournTime = sum(taxiTakeoffSojournTimes, "omitnan");
    singleDayStats.taxiTakeoff.meanQueueingDelayPerExternalAircraft = ...
        mean(taxiTakeoffQueueingDelays, "omitnan");
    singleDayStats.taxiTakeoff.meanServiceTimePerExternalAircraft = ...
        mean(taxiTakeoffServiceTimes, "omitnan");
    singleDayStats.taxiTakeoff.meanSojournTimePerExternalAircraft = ...
        mean(taxiTakeoffSojournTimes, "omitnan");
    singleDayStats.taxiTakeoff.p95QueueingDelay = ...
        safePrctile(taxiTakeoffQueueingDelays, 95);
    singleDayStats.taxiTakeoff.p95SojournTime = ...
        safePrctile(taxiTakeoffSojournTimes, 95);

    singleDayStats.groundSojourn = struct();
    singleDayStats.groundSojourn.numAircraftIncluded = numDepartures;
    singleDayStats.groundSojourn.totalGroundSojournTime = sum(groundSojournTimes, "omitnan");
    singleDayStats.groundSojourn.meanGroundSojournTime = safeMean(groundSojournTimes);
    singleDayStats.groundSojourn.medianGroundSojournTime = safeMedian(groundSojournTimes);
    singleDayStats.groundSojourn.p90GroundSojournTime = safePrctile(groundSojournTimes, 90);
    singleDayStats.groundSojourn.p95GroundSojournTime = safePrctile(groundSojournTimes, 95);
    singleDayStats.groundSojourn.p99GroundSojournTime = safePrctile(groundSojournTimes, 99);
    singleDayStats.groundSojourn.maxGroundSojournTime = safeMax(groundSojournTimes);

    singleDayStats.departureDelay = struct();
    singleDayStats.departureDelay.numAircraftIncluded = numDepartures;
    singleDayStats.departureDelay.delayCostThresholds = delayCostThresholds;
    singleDayStats.departureDelay.totalDepartureDelay = sum(departureDelays, "omitnan");
    singleDayStats.departureDelay.totalPositiveDepartureDelay = ...
        sum(positiveDepartureDelays, "omitnan");
    singleDayStats.departureDelay.meanDepartureDelay = safeMean(departureDelays);
    singleDayStats.departureDelay.meanPositiveDepartureDelay = ...
        safeMean(positiveDepartureDelays);
    singleDayStats.departureDelay.medianPositiveDepartureDelay = ...
        safeMedian(positiveDepartureDelays);
    singleDayStats.departureDelay.p90PositiveDepartureDelay = ...
        safePrctile(positiveDepartureDelays, 90);
    singleDayStats.departureDelay.p95PositiveDepartureDelay = ...
        safePrctile(positiveDepartureDelays, 95);
    singleDayStats.departureDelay.p99PositiveDepartureDelay = ...
        safePrctile(positiveDepartureDelays, 99);
    singleDayStats.departureDelay.maxPositiveDepartureDelay = ...
        safeMax(positiveDepartureDelays);

    singleDayStats.departureDelay.totalDelayAboveD1 = ...
        sum(max(positiveDepartureDelays - delayCostThresholds(1), 0), "omitnan");
    singleDayStats.departureDelay.totalDelayAboveD2 = ...
        sum(max(positiveDepartureDelays - delayCostThresholds(2), 0), "omitnan");
    singleDayStats.departureDelay.totalDelayAboveD3 = ...
        sum(max(positiveDepartureDelays - delayCostThresholds(3), 0), "omitnan");

    singleDayStats.departureDelay.probDelayAboveD1 = ...
        safeMean(positiveDepartureDelays > delayCostThresholds(1));
    singleDayStats.departureDelay.probDelayAboveD2 = ...
        safeMean(positiveDepartureDelays > delayCostThresholds(2));
    singleDayStats.departureDelay.probDelayAboveD3 = ...
        safeMean(positiveDepartureDelays > delayCostThresholds(3));

    singleDayStats.typeStats = computeAircraftTypeStats( ...
        aircraftTypes, ...
        departedMask, ...
        cancelledMask, ...
        numDeicingCycles, ...
        numHOTViolationsByAircraft, ...
        actualTakeoffTimes, ...
        initialArrivalTimes, ...
        scheduledTakeoffTimes, ...
        deicingQueueingDelays, ...
        deicingServiceTimes, ...
        taxiTakeoffQueueingDelays, ...
        taxiTakeoffServiceTimes, ...
        taxiTakeoffSojournTimes);

    singleDayStats.diagnostics = struct();
    singleDayStats.diagnostics.allAircraftResolved = ...
        all(departedMask | cancelledMask);
    singleDayStats.diagnostics.allAircraftDeparted = all(departedMask);
    singleDayStats.diagnostics.anyAircraftCancelled = any(cancelledMask);
    singleDayStats.diagnostics.finalClockTime = getFinalClockTime(simContext.clock);
    singleDayStats.diagnostics.finalEventCalendarEmpty = ...
        isEventCalendarEmpty(simContext.eventCalendar);
    singleDayStats.diagnostics.finalDeicingQueueLength = ...
        numel(simContext.state.deicingQueue);
    singleDayStats.diagnostics.finalTaxiTakeoffQueueLength = ...
        numel(simContext.state.taxiTakeoffQueue);

    singleDayStats.cost = computeSingleDayDESCost(singleDayStats, costModel);
end

function typeStats = computeAircraftTypeStats( ...
    aircraftTypes, ...
    departedMask, ...
    cancelledMask, ...
    numDeicingCycles, ...
    numHOTViolationsByAircraft, ...
    actualTakeoffTimes, ...
    initialArrivalTimes, ...
    scheduledTakeoffTimes, ...
    deicingQueueingDelays, ...
    deicingServiceTimes, ...
    taxiTakeoffQueueingDelays, ...
    taxiTakeoffServiceTimes, ...
    taxiTakeoffSojournTimes)

    aircraftTypeInfo = getAircraftTypeInfo();
    uniqueTypes = aircraftTypeInfo.names;

    typeStats = struct();

    for idxType = 1:numel(uniqueTypes)
        currentType = uniqueTypes(idxType);
        typeMask = aircraftTypes == currentType;

        currentFieldName = matlab.lang.makeValidName(currentType);

        if ~any(typeMask)
            typeStats.(currentFieldName) = buildEmptyAircraftTypeStats(currentType);
            continue;
        end

        departedTypeMask = typeMask & departedMask;
        cancelledTypeMask = typeMask & cancelledMask;

        typeGroundSojournTimes = ...
            actualTakeoffTimes(departedTypeMask) - initialArrivalTimes(departedTypeMask);

        typeDepartureDelays = ...
            actualTakeoffTimes(departedTypeMask) - scheduledTakeoffTimes(departedTypeMask);

        typePositiveDepartureDelays = max(typeDepartureDelays, 0);

        typeStats.(currentFieldName) = struct();
        typeStats.(currentFieldName).type = currentType;
        typeStats.(currentFieldName).numAircraft = sum(typeMask);
        typeStats.(currentFieldName).numDepartures = sum(departedTypeMask);
        typeStats.(currentFieldName).numCancellations = sum(cancelledTypeMask);
        typeStats.(currentFieldName).cancellationRate = ...
            safeDivide(sum(cancelledTypeMask), sum(typeMask));

        typeStats.(currentFieldName).totalDeicingJobs = ...
            sum(numDeicingCycles(typeMask), "omitnan");
        typeStats.(currentFieldName).numHOTViolations = ...
            sum(numHOTViolationsByAircraft(typeMask), "omitnan");
        typeStats.(currentFieldName).meanDeicingCycles = ...
            mean(numDeicingCycles(typeMask), "omitnan");

        typeStats.(currentFieldName).meanGroundSojournTime = ...
            safeMean(typeGroundSojournTimes);
        typeStats.(currentFieldName).p95GroundSojournTime = ...
            safePrctile(typeGroundSojournTimes, 95);

        typeStats.(currentFieldName).meanDepartureDelay = ...
            safeMean(typeDepartureDelays);
        typeStats.(currentFieldName).meanPositiveDepartureDelay = ...
            safeMean(typePositiveDepartureDelays);
        typeStats.(currentFieldName).p95PositiveDepartureDelay = ...
            safePrctile(typePositiveDepartureDelays, 95);

        typeStats.(currentFieldName).meanDeicingQueueingDelay = ...
            mean(deicingQueueingDelays(typeMask), "omitnan");
        typeStats.(currentFieldName).meanDeicingServiceTime = ...
            mean(deicingServiceTimes(typeMask), "omitnan");

        typeStats.(currentFieldName).meanTaxiTakeoffQueueingDelay = ...
            mean(taxiTakeoffQueueingDelays(typeMask), "omitnan");
        typeStats.(currentFieldName).meanTaxiTakeoffServiceTime = ...
            mean(taxiTakeoffServiceTimes(typeMask), "omitnan");
        typeStats.(currentFieldName).meanTaxiTakeoffSojournTime = ...
            mean(taxiTakeoffSojournTimes(typeMask), "omitnan");
    end
end

function emptyStats = buildEmptyAircraftTypeStats(aircraftType)
    emptyStats = struct();
    emptyStats.type = aircraftType;
    emptyStats.numAircraft = 0;
    emptyStats.numDepartures = 0;
    emptyStats.numCancellations = 0;
    emptyStats.cancellationRate = NaN;
    emptyStats.totalDeicingJobs = 0;
    emptyStats.numHOTViolations = 0;
    emptyStats.meanDeicingCycles = NaN;
    emptyStats.meanGroundSojournTime = NaN;
    emptyStats.p95GroundSojournTime = NaN;
    emptyStats.meanDepartureDelay = NaN;
    emptyStats.meanPositiveDepartureDelay = NaN;
    emptyStats.p95PositiveDepartureDelay = NaN;
    emptyStats.meanDeicingQueueingDelay = NaN;
    emptyStats.meanDeicingServiceTime = NaN;
    emptyStats.meanTaxiTakeoffQueueingDelay = NaN;
    emptyStats.meanTaxiTakeoffServiceTime = NaN;
    emptyStats.meanTaxiTakeoffSojournTime = NaN;
end

function singleDayStats = buildEmptySingleDayStats()
    singleDayStats = struct();

    singleDayStats.status = struct();
    singleDayStats.status.numDepartures = 0;
    singleDayStats.status.numCancellations = 0;
    singleDayStats.status.numUnresolvedAircraft = 0;
    singleDayStats.status.departureRate = NaN;
    singleDayStats.status.cancellationRate = NaN;
    singleDayStats.status.unresolvedRate = NaN;

    singleDayStats.volume = struct();
    singleDayStats.volume.numExternalArrivals = 0;
    singleDayStats.volume.numDepartures = 0;
    singleDayStats.volume.numCancellations = 0;
    singleDayStats.volume.totalDeicingJobs = 0;
    singleDayStats.volume.meanDeicingJobsPerExternalAircraft = NaN;
    singleDayStats.volume.numHOTViolations = 0;
    singleDayStats.volume.hotViolationRatePerExternalAircraft = NaN;
    singleDayStats.volume.hotViolationRatePerDeicingJob = NaN;

    singleDayStats.cancellation = struct();
    singleDayStats.cancellation.numCancellations = 0;
    singleDayStats.cancellation.cancellationRate = NaN;
    singleDayStats.cancellation.totalCancellationCost = 0;

    singleDayStats.deicing = struct();
    singleDayStats.taxiTakeoff = struct();
    singleDayStats.groundSojourn = struct();
    singleDayStats.departureDelay = struct();
    singleDayStats.typeStats = struct();
    singleDayStats.diagnostics = struct();
end

function finalClockTime = getFinalClockTime(clockState)
    if isstruct(clockState) && isfield(clockState, "currentTime")
        finalClockTime = clockState.currentTime;
    else
        finalClockTime = clockState;
    end
end

function quotient = safeDivide(numerator, denominator)
    if denominator == 0
        quotient = NaN;
    else
        quotient = numerator / denominator;
    end
end

function value = safeMean(values)
    values = values(~isnan(values));
    if isempty(values)
        value = NaN;
    else
        value = mean(values);
    end
end

function value = safeMedian(values)
    values = values(~isnan(values));
    if isempty(values)
        value = NaN;
    else
        value = median(values);
    end
end

function value = safePrctile(values, percentile)
    values = values(~isnan(values));
    if isempty(values)
        value = NaN;
    else
        value = prctile(values, percentile);
    end
end

function value = safeMax(values)
    values = values(~isnan(values));
    if isempty(values)
        value = NaN;
    else
        value = max(values);
    end
end