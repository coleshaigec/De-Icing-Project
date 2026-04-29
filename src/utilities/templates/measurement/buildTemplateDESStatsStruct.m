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
    stats.observations.deicingWaitTimes = [];
    stats.observations.deicingServiceTimes = [];
    stats.observations.taxiTakeoffSojournTimes = [];
    stats.observations.groundSojournTimes = [];
    stats.observations.hotElapsedTimes = [];
    stats.observations.hotLimits = [];
    stats.observations.numDeicingCyclesByAircraft = [];

    stats.typeObservations = struct();
    stats.typeObservations.initialArrivalAircraftTypes = strings(0, 1);
    stats.typeObservations.deicingServiceAircraftTypes = strings(0, 1);
    stats.typeObservations.taxiTakeoffAircraftTypes = strings(0, 1);
    stats.typeObservations.departureAircraftTypes = strings(0, 1);
    stats.typeObservations.hotViolationAircraftTypes = strings(0, 1);

    stats.costInputs = struct();
    stats.costInputs.totalDeicingServiceTime = [];
    stats.costInputs.totalTaxiTakeoffTime = [];
    stats.costInputs.totalDelayPenaltyProxy = [];
    stats.costInputs.totalFluidUseProxy = [];
    stats.costInputs.totalActivationProxy = [];
end