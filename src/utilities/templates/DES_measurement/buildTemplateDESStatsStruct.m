function stats = buildTemplateDESStatsStruct()
    % BUILDTEMPLATEDESSTATSSTRUCT Builds template DES statistics accumulator.
    %
    % OUTPUT
    %  stats struct with fields
    %      .time struct
    %      .integrals struct
    %      .counts struct
    %      .observations struct
    %      .typeObservations struct
    %      .idObservations struct
    %      .tailRisk struct
    %      .costInputs struct

    stats = struct();

    stats.time = struct();
    stats.time.startTime = [];
    stats.time.endTime = [];
    stats.time.lastEventTime = [];

    stats.integrals = struct();
    stats.integrals.deicingQueueLength = [];
    stats.integrals.deicingSystemPopulation = [];
    stats.integrals.busyDeicingServers = [];
    stats.integrals.taxiTakeoffSystemPopulation = [];

    stats.counts = struct();
    stats.counts.numInitialArrivals = [];
    stats.counts.numTotalDeicingQueueEntries = [];
    stats.counts.numDeicingStarts = [];
    stats.counts.numDeicingCompletions = [];
    stats.counts.numTaxiTakeoffEntries = [];
    stats.counts.numDepartureAttempts = [];
    stats.counts.numSuccessfulDepartures = [];
    stats.counts.numHOTViolations = [];
    stats.counts.numReworkQueueEntries = [];

    stats.observations = struct();
    stats.observations.deicingQueueEntryTimes = [];
    stats.observations.deicingStartTimes = [];
    stats.observations.deicingCompletionTimes = [];
    stats.observations.taxiTakeoffEntryTimes = [];
    stats.observations.departureAttemptTimes = [];
    stats.observations.successfulDepartureTimes = [];
    stats.observations.hotViolationTimes = [];

    stats.observations.deicingWaitTimes = [];
    stats.observations.deicingServiceTimes = [];
    stats.observations.taxiTakeoffSojournTimes = [];
    stats.observations.groundSojournTimes = [];
    stats.observations.hotElapsedTimes = [];
    stats.observations.hotLimits = [];
    stats.observations.numDeicingCyclesByAircraft = [];

    stats.observations.groundDelayBeyondNominal = [];
    stats.observations.excessGroundSojournStage1 = [];
    stats.observations.excessGroundSojournStage2 = [];
    stats.observations.excessGroundSojournStage3 = [];

    stats.typeObservations = struct();
    stats.typeObservations.initialArrivalAircraftTypes = strings(0, 1);
    stats.typeObservations.deicingQueueEntryAircraftTypes = strings(0, 1);
    stats.typeObservations.deicingServiceAircraftTypes = strings(0, 1);
    stats.typeObservations.taxiTakeoffAircraftTypes = strings(0, 1);
    stats.typeObservations.departureAircraftTypes = strings(0, 1);
    stats.typeObservations.hotViolationAircraftTypes = strings(0, 1);

    stats.idObservations = struct();
    stats.idObservations.initialArrivalAircraftIDs = [];
    stats.idObservations.deicingQueueEntryAircraftIDs = [];
    stats.idObservations.deicingServiceAircraftIDs = [];
    stats.idObservations.taxiTakeoffAircraftIDs = [];
    stats.idObservations.departureAircraftIDs = [];
    stats.idObservations.hotViolationAircraftIDs = [];

    stats.tailRisk = struct();
    stats.tailRisk.numGroundSojournsAboveThreshold1 = [];
    stats.tailRisk.numGroundSojournsAboveThreshold2 = [];
    stats.tailRisk.numGroundSojournsAboveThreshold3 = [];
    stats.tailRisk.maxGroundSojournTime = [];
    stats.tailRisk.maxDeicingWaitTime = [];
    stats.tailRisk.maxTaxiTakeoffSojournTime = [];

    stats.costInputs = struct();
    stats.costInputs.numActivatedDeicingServers = [];
    stats.costInputs.deicingCapacityLevel = [];
    stats.costInputs.stormSeverity = [];

    stats.costInputs.fluidCostByAircraft = [];
    stats.costInputs.fluidCostTotal = [];

    stats.costInputs.activationCost = [];
    stats.costInputs.delayCostByAircraft = [];
    stats.costInputs.delayCostTotal = [];
    stats.costInputs.hotViolationPenaltyCost = [];
    stats.costInputs.totalDayCost = [];
end