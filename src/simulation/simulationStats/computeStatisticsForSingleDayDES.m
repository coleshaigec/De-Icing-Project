function singleDayStats = computeStatisticsForSingleDayDES(simContext, delayCostThresholds, costModel)
    % COMPUTESTATISTICSFORSINGLEDAYDES Computes results of single-day DES via Monte Carlo estimation.
    %
    % INPUTS
    %  simContext struct
    %      Terminal simulation context returned after the single-day DES event
    %      calendar has been fully processed. This function treats
    %      simContext.state.aircraft as the source of truth for aircraft-level
    %      histories and aggregates those histories into day-level Monte Carlo
    %      estimates.
    %
    %  delayCostThresholds (1, 3) double
    %      Delay thresholds [d1, d2, d3] in minutes used for the piecewise-linear
    %      delay-cost regime. These thresholds are applied to positive departure
    %      delay, defined as max(actualTakeoffTime - STD, 0).
    %
    % OUTPUT
    %  singleDayStats struct with fields
    %
    %      .policy
    %          Copy of simContext.policy for traceability. Contains the capacity
    %          policy used for the simulated day.
    %
    %      .storm
    %          Copy of simContext.storm for traceability. Contains the sampled
    %          storm-day severity, duration, and cost multipliers.
    %
    %      .volume struct with fields
    %          .numExternalArrivals
    %              Number of external aircraft arrivals generated for the day.
    %
    %          .totalDeicingJobs
    %              Total number of de-icing service cycles completed during the
    %              day. This includes first-pass de-icing jobs and repeat jobs
    %              induced by HOT violations.
    %
    %          .meanDeicingJobsPerExternalAircraft
    %              Mean number of de-icing jobs required per external aircraft.
    %
    %          .numHOTViolations
    %              Total number of HOT violations, computed as total de-icing
    %              jobs minus external aircraft arrivals.
    %
    %          .hotViolationRatePerExternalAircraft
    %              HOT violations divided by external aircraft arrivals.
    %
    %          .hotViolationRatePerDeicingJob
    %              HOT violations divided by total de-icing jobs.
    %
    %      .deicing struct with fields
    %          .totalQueueingDelay
    %              Total aircraft-minutes spent waiting in the de-icing queue.
    %
    %          .totalServiceTime
    %              Total aircraft-minutes spent receiving de-icing service.
    %
    %          .meanQueueingDelayPerExternalAircraft
    %              Mean de-icing queueing delay per external aircraft.
    %
    %          .meanServiceTimePerExternalAircraft
    %              Mean total de-icing service time per external aircraft,
    %              including repeated service cycles caused by HOT violations.
    %
    %          .p95QueueingDelay
    %              95th percentile of aircraft-level total de-icing queueing
    %              delay.
    %
    %          .p95ServiceTime
    %              95th percentile of aircraft-level total de-icing service time.
    %
    %      .taxiTakeoff struct with fields
    %          .totalQueueingDelay
    %              Total aircraft-minutes spent waiting for taxi/takeoff service.
    %
    %          .totalServiceTime
    %              Total aircraft-minutes spent in taxi/takeoff service.
    %
    %          .totalSojournTime
    %              Total aircraft-minutes spent in the taxi/takeoff subsystem,
    %              including both queueing and service.
    %
    %          .meanQueueingDelayPerExternalAircraft
    %              Mean taxi/takeoff queueing delay per external aircraft.
    %
    %          .meanServiceTimePerExternalAircraft
    %              Mean taxi/takeoff service time per external aircraft.
    %
    %          .meanSojournTimePerExternalAircraft
    %              Mean taxi/takeoff queueing plus service time per external
    %              aircraft.
    %
    %          .p95QueueingDelay
    %              95th percentile of aircraft-level taxi/takeoff queueing delay.
    %
    %          .p95SojournTime
    %              95th percentile of aircraft-level taxi/takeoff sojourn time.
    %
    %      .groundSojourn struct with fields
    %          .totalGroundSojournTime
    %              Total aircraft-minutes from initial arrival to final takeoff.
    %
    %          .meanGroundSojournTime
    %              Mean elapsed time from initial arrival to final takeoff.
    %
    %          .medianGroundSojournTime
    %              Median elapsed time from initial arrival to final takeoff.
    %
    %          .p90GroundSojournTime
    %              90th percentile of aircraft-level ground sojourn time.
    %
    %          .p95GroundSojournTime
    %              95th percentile of aircraft-level ground sojourn time.
    %
    %          .p99GroundSojournTime
    %              99th percentile of aircraft-level ground sojourn time.
    %
    %          .maxGroundSojournTime
    %              Maximum aircraft-level ground sojourn time observed during the
    %              simulated day.
    %
    %      .departureDelay struct with fields
    %          .delayCostThresholds
    %              Copy of the delay thresholds [d1, d2, d3] used for cost
    %              calculations.
    %
    %          .totalDepartureDelay
    %              Sum of signed departure delays, actualTakeoffTime - STD.
    %
    %          .totalPositiveDepartureDelay
    %              Sum of nonnegative departure delays, max(actualTakeoffTime - STD, 0).
    %
    %          .meanDepartureDelay
    %              Mean signed departure delay per external aircraft.
    %
    %          .meanPositiveDepartureDelay
    %              Mean nonnegative departure delay per external aircraft.
    %
    %          .medianPositiveDepartureDelay
    %              Median nonnegative departure delay.
    %
    %          .p90PositiveDepartureDelay
    %              90th percentile of nonnegative departure delay.
    %
    %          .p95PositiveDepartureDelay
    %              95th percentile of nonnegative departure delay.
    %
    %          .p99PositiveDepartureDelay
    %              99th percentile of nonnegative departure delay.
    %
    %          .maxPositiveDepartureDelay
    %              Maximum nonnegative departure delay.
    %
    %          .totalDelayAboveD1
    %              Sum of positive delay minutes above delayCostThresholds(1).
    %
    %          .totalDelayAboveD2
    %              Sum of positive delay minutes above delayCostThresholds(2).
    %
    %          .totalDelayAboveD3
    %              Sum of positive delay minutes above delayCostThresholds(3).
    %
    %          .probDelayAboveD1
    %              Fraction of aircraft with positive delay above delayCostThresholds(1).
    %
    %          .probDelayAboveD2
    %              Fraction of aircraft with positive delay above delayCostThresholds(2).
    %
    %          .probDelayAboveD3
    %              Fraction of aircraft with positive delay above delayCostThresholds(3).
    %
    %      .typeStats struct
    %          Type-specific diagnostic statistics grouped by aircraft type. Each
    %          aircraft type is stored as a substruct whose field name is generated
    %          from the aircraft type string using matlab.lang.makeValidName.
    %          For example:
    %
    %              singleDayStats.typeStats.E175
    %              singleDayStats.typeStats.A320
    %              singleDayStats.typeStats.B757
    %              singleDayStats.typeStats.A350
    %
    %          Each aircraft-type substruct contains:
    %
    %              .type
    %              .numAircraft
    %              .totalDeicingJobs
    %              .numHOTViolations
    %              .meanDeicingCycles
    %              .meanGroundSojournTime
    %              .p95GroundSojournTime
    %              .meanDepartureDelay
    %              .meanPositiveDepartureDelay
    %              .p95PositiveDepartureDelay
    %              .meanDeicingQueueingDelay
    %              .meanDeicingServiceTime
    %              .meanTaxiTakeoffQueueingDelay
    %              .meanTaxiTakeoffServiceTime
    %              .meanTaxiTakeoffSojournTime
    %
    %      .diagnostics struct with fields
    %          .allAircraftDeparted
    %              Logical flag indicating whether all tracked aircraft ended the
    %              simulation in the "departed" state.
    %
    %          .finalClockTime
    %              Terminal simulation clock time.
    %
    %          .finalEventCalendarEmpty
    %              Logical flag indicating whether the event calendar is empty at
    %              the end of the simulation.
    %
    %          .finalDeicingQueueLength
    %              Number of aircraft remaining in the de-icing queue at terminal
    %              simulation time.
    %
    %          .finalTaxiTakeoffQueueLength
    %              Number of aircraft remaining in the taxi/takeoff queue at
    %              terminal simulation time.

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

    groundSojournTimes = actualTakeoffTimes - initialArrivalTimes;
    taxiTakeoffSojournTimes = taxiTakeoffQueueingDelays + taxiTakeoffServiceTimes;
    departureDelays = actualTakeoffTimes - scheduledTakeoffTimes;
    positiveDepartureDelays = max(departureDelays, 0);

    numExternalArrivals = numel(aircraft);
    totalDeicingJobs = sum(numDeicingCycles);
    numHOTViolations = totalDeicingJobs - numExternalArrivals;

    % -- Populate output struct --
    singleDayStats = struct();

    singleDayStats.policy = simContext.policy;
    singleDayStats.storm = simContext.storm;

    singleDayStats.volume = struct();
    singleDayStats.volume.numExternalArrivals = numExternalArrivals;
    singleDayStats.volume.totalDeicingJobs = totalDeicingJobs;
    singleDayStats.volume.meanDeicingJobsPerExternalAircraft = ...
        totalDeicingJobs / numExternalArrivals;
    singleDayStats.volume.numHOTViolations = numHOTViolations;
    singleDayStats.volume.hotViolationRatePerExternalAircraft = ...
        numHOTViolations / numExternalArrivals;
    singleDayStats.volume.hotViolationRatePerDeicingJob = ...
        safeDivide(numHOTViolations, totalDeicingJobs);

    singleDayStats.deicing = struct();
    singleDayStats.deicing.totalQueueingDelay = sum(deicingQueueingDelays);
    singleDayStats.deicing.totalServiceTime = sum(deicingServiceTimes);
    singleDayStats.deicing.meanQueueingDelayPerExternalAircraft = ...
        mean(deicingQueueingDelays);
    singleDayStats.deicing.meanServiceTimePerExternalAircraft = ...
        mean(deicingServiceTimes);
    singleDayStats.deicing.p95QueueingDelay = prctile(deicingQueueingDelays, 95);
    singleDayStats.deicing.p95ServiceTime = prctile(deicingServiceTimes, 95);

    singleDayStats.taxiTakeoff = struct();
    singleDayStats.taxiTakeoff.totalQueueingDelay = sum(taxiTakeoffQueueingDelays);
    singleDayStats.taxiTakeoff.totalServiceTime = sum(taxiTakeoffServiceTimes);
    singleDayStats.taxiTakeoff.totalSojournTime = sum(taxiTakeoffSojournTimes);
    singleDayStats.taxiTakeoff.meanQueueingDelayPerExternalAircraft = ...
        mean(taxiTakeoffQueueingDelays);
    singleDayStats.taxiTakeoff.meanServiceTimePerExternalAircraft = ...
        mean(taxiTakeoffServiceTimes);
    singleDayStats.taxiTakeoff.meanSojournTimePerExternalAircraft = ...
        mean(taxiTakeoffSojournTimes);
    singleDayStats.taxiTakeoff.p95QueueingDelay = ...
        prctile(taxiTakeoffQueueingDelays, 95);
    singleDayStats.taxiTakeoff.p95SojournTime = ...
        prctile(taxiTakeoffSojournTimes, 95);

    singleDayStats.groundSojourn = struct();
    singleDayStats.groundSojourn.totalGroundSojournTime = sum(groundSojournTimes);
    singleDayStats.groundSojourn.meanGroundSojournTime = mean(groundSojournTimes);
    singleDayStats.groundSojourn.medianGroundSojournTime = median(groundSojournTimes);
    singleDayStats.groundSojourn.p90GroundSojournTime = prctile(groundSojournTimes, 90);
    singleDayStats.groundSojourn.p95GroundSojournTime = prctile(groundSojournTimes, 95);
    singleDayStats.groundSojourn.p99GroundSojournTime = prctile(groundSojournTimes, 99);
    singleDayStats.groundSojourn.maxGroundSojournTime = max(groundSojournTimes);

    singleDayStats.departureDelay = struct();
    singleDayStats.departureDelay.delayCostThresholds = delayCostThresholds;
    singleDayStats.departureDelay.totalDepartureDelay = sum(departureDelays);
    singleDayStats.departureDelay.totalPositiveDepartureDelay = ...
        sum(positiveDepartureDelays);
    singleDayStats.departureDelay.meanDepartureDelay = mean(departureDelays);
    singleDayStats.departureDelay.meanPositiveDepartureDelay = ...
        mean(positiveDepartureDelays);
    singleDayStats.departureDelay.medianPositiveDepartureDelay = ...
        median(positiveDepartureDelays);
    singleDayStats.departureDelay.p90PositiveDepartureDelay = ...
        prctile(positiveDepartureDelays, 90);
    singleDayStats.departureDelay.p95PositiveDepartureDelay = ...
        prctile(positiveDepartureDelays, 95);
    singleDayStats.departureDelay.p99PositiveDepartureDelay = ...
        prctile(positiveDepartureDelays, 99);
    singleDayStats.departureDelay.maxPositiveDepartureDelay = ...
        max(positiveDepartureDelays);

    singleDayStats.departureDelay.totalDelayAboveD1 = ...
        sum(max(positiveDepartureDelays - delayCostThresholds(1), 0));
    singleDayStats.departureDelay.totalDelayAboveD2 = ...
        sum(max(positiveDepartureDelays - delayCostThresholds(2), 0));
    singleDayStats.departureDelay.totalDelayAboveD3 = ...
        sum(max(positiveDepartureDelays - delayCostThresholds(3), 0));

    singleDayStats.departureDelay.probDelayAboveD1 = ...
        mean(positiveDepartureDelays > delayCostThresholds(1));
    singleDayStats.departureDelay.probDelayAboveD2 = ...
        mean(positiveDepartureDelays > delayCostThresholds(2));
    singleDayStats.departureDelay.probDelayAboveD3 = ...
        mean(positiveDepartureDelays > delayCostThresholds(3));

    singleDayStats.typeStats = computeAircraftTypeStats( ...
        aircraftTypes, ...
        numDeicingCycles, ...
        groundSojournTimes, ...
        departureDelays, ...
        positiveDepartureDelays, ...
        deicingQueueingDelays, ...
        deicingServiceTimes, ...
        taxiTakeoffQueueingDelays, ...
        taxiTakeoffServiceTimes, ...
        taxiTakeoffSojournTimes);

    singleDayStats.diagnostics = struct();
    singleDayStats.diagnostics.allAircraftDeparted = ...
        all(strcmp(string({aircraft.currentLocation}), "departed"));
    singleDayStats.diagnostics.finalClockTime = simContext.clock;
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
    numDeicingCycles, ...
    groundSojournTimes, ...
    departureDelays, ...
    positiveDepartureDelays, ...
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

        typeStats.(currentFieldName) = struct();
        typeStats.(currentFieldName).type = currentType;
        typeStats.(currentFieldName).numAircraft = sum(typeMask);
        typeStats.(currentFieldName).totalDeicingJobs = ...
            sum(numDeicingCycles(typeMask));
        typeStats.(currentFieldName).numHOTViolations = ...
            sum(numDeicingCycles(typeMask)) - sum(typeMask);
        typeStats.(currentFieldName).meanDeicingCycles = ...
            mean(numDeicingCycles(typeMask));

        typeStats.(currentFieldName).meanGroundSojournTime = ...
            mean(groundSojournTimes(typeMask));
        typeStats.(currentFieldName).p95GroundSojournTime = ...
            prctile(groundSojournTimes(typeMask), 95);

        typeStats.(currentFieldName).meanDepartureDelay = ...
            mean(departureDelays(typeMask));
        typeStats.(currentFieldName).meanPositiveDepartureDelay = ...
            mean(positiveDepartureDelays(typeMask));
        typeStats.(currentFieldName).p95PositiveDepartureDelay = ...
            prctile(positiveDepartureDelays(typeMask), 95);

        typeStats.(currentFieldName).meanDeicingQueueingDelay = ...
            mean(deicingQueueingDelays(typeMask));
        typeStats.(currentFieldName).meanDeicingServiceTime = ...
            mean(deicingServiceTimes(typeMask));

        typeStats.(currentFieldName).meanTaxiTakeoffQueueingDelay = ...
            mean(taxiTakeoffQueueingDelays(typeMask));
        typeStats.(currentFieldName).meanTaxiTakeoffServiceTime = ...
            mean(taxiTakeoffServiceTimes(typeMask));
        typeStats.(currentFieldName).meanTaxiTakeoffSojournTime = ...
            mean(taxiTakeoffSojournTimes(typeMask));
    end
end

function emptyStats = buildEmptyAircraftTypeStats(aircraftType)
    emptyStats = struct();
    emptyStats.type = aircraftType;
    emptyStats.numAircraft = 0;
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

    singleDayStats.volume = struct();
    singleDayStats.volume.numExternalArrivals = 0;
    singleDayStats.volume.totalDeicingJobs = 0;
    singleDayStats.volume.meanDeicingJobsPerExternalAircraft = NaN;
    singleDayStats.volume.numHOTViolations = 0;
    singleDayStats.volume.hotViolationRatePerExternalAircraft = NaN;
    singleDayStats.volume.hotViolationRatePerDeicingJob = NaN;

    singleDayStats.deicing = struct();
    singleDayStats.taxiTakeoff = struct();
    singleDayStats.groundSojourn = struct();
    singleDayStats.departureDelay = struct();
    singleDayStats.typeStats = struct();
    singleDayStats.diagnostics = struct();
end

function quotient = safeDivide(numerator, denominator)
    if denominator == 0
        quotient = NaN;
    else
        quotient = numerator / denominator;
    end
end