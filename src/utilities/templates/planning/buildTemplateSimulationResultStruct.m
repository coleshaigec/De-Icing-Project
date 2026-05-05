function templateSimulationResult = buildTemplateSimulationResultStruct()
    % BUILDTEMPLATESIMULATIONRESULTSTRUCT Builds template paired annual simulation result struct.
    %
    % OUTPUT
    %  templateSimulationResult struct
    %      Template struct matching aggregateDayLevelSimulationResults output.
    %      Contains separate annual aggregate schemas for DES and analytic model.

    templateSingleModelResult = buildTemplateSingleModelSimulationResultStruct();

    templateSimulationResult = struct();
    templateSimulationResult.DES = templateSingleModelResult;
    templateSimulationResult.analyticModel = templateSingleModelResult;
    templateSimulationResult.simulationPlan = struct();
end

function templateSingleModelResult = buildTemplateSingleModelSimulationResultStruct()
    templateSingleModelResult = struct();

    templateSingleModelResult.numDays = NaN;
    templateSingleModelResult.policy = struct();

    templateSingleModelResult.volume = struct();
    templateSingleModelResult.volume.totalExternalArrivals = NaN;
    templateSingleModelResult.volume.totalDeicingJobs = NaN;
    templateSingleModelResult.volume.totalHOTViolations = NaN;
    templateSingleModelResult.volume.meanExternalArrivalsPerDay = NaN;
    templateSingleModelResult.volume.stdExternalArrivalsPerDay = NaN;
    templateSingleModelResult.volume.p95ExternalArrivalsPerDay = NaN;
    templateSingleModelResult.volume.maxExternalArrivalsPerDay = NaN;
    templateSingleModelResult.volume.meanDeicingJobsPerDay = NaN;
    templateSingleModelResult.volume.stdDeicingJobsPerDay = NaN;
    templateSingleModelResult.volume.p95DeicingJobsPerDay = NaN;
    templateSingleModelResult.volume.maxDeicingJobsPerDay = NaN;
    templateSingleModelResult.volume.meanHOTViolationsPerDay = NaN;
    templateSingleModelResult.volume.p95HOTViolationsPerDay = NaN;
    templateSingleModelResult.volume.maxHOTViolationsPerDay = NaN;
    templateSingleModelResult.volume.numDaysWithHOTViolations = NaN;
    templateSingleModelResult.volume.meanDeicingJobsPerExternalAircraft = NaN;
    templateSingleModelResult.volume.hotViolationRatePerExternalAircraft = NaN;
    templateSingleModelResult.volume.hotViolationRatePerDeicingJob = NaN;

    templateSingleModelResult.deicing = struct();
    templateSingleModelResult.deicing.totalQueueingDelay = NaN;
    templateSingleModelResult.deicing.totalServiceTime = NaN;
    templateSingleModelResult.deicing.meanQueueingDelayAcrossDays = NaN;
    templateSingleModelResult.deicing.stdMeanQueueingDelayAcrossDays = NaN;
    templateSingleModelResult.deicing.p95MeanQueueingDelayAcrossDays = NaN;
    templateSingleModelResult.deicing.meanServiceTimeAcrossDays = NaN;
    templateSingleModelResult.deicing.stdMeanServiceTimeAcrossDays = NaN;
    templateSingleModelResult.deicing.p95MeanServiceTimeAcrossDays = NaN;
    templateSingleModelResult.deicing.meanDailyP95QueueingDelay = NaN;
    templateSingleModelResult.deicing.p95DailyP95QueueingDelay = NaN;
    templateSingleModelResult.deicing.meanDailyP95ServiceTime = NaN;
    templateSingleModelResult.deicing.p95DailyP95ServiceTime = NaN;

    templateSingleModelResult.taxiTakeoff = struct();
    templateSingleModelResult.taxiTakeoff.totalQueueingDelay = NaN;
    templateSingleModelResult.taxiTakeoff.totalServiceTime = NaN;
    templateSingleModelResult.taxiTakeoff.totalSojournTime = NaN;
    templateSingleModelResult.taxiTakeoff.meanQueueingDelayAcrossDays = NaN;
    templateSingleModelResult.taxiTakeoff.stdMeanQueueingDelayAcrossDays = NaN;
    templateSingleModelResult.taxiTakeoff.meanServiceTimeAcrossDays = NaN;
    templateSingleModelResult.taxiTakeoff.meanSojournTimeAcrossDays = NaN;
    templateSingleModelResult.taxiTakeoff.stdMeanSojournTimeAcrossDays = NaN;
    templateSingleModelResult.taxiTakeoff.p95MeanSojournTimeAcrossDays = NaN;
    templateSingleModelResult.taxiTakeoff.meanDailyP95SojournTime = NaN;
    templateSingleModelResult.taxiTakeoff.p95DailyP95SojournTime = NaN;

    templateSingleModelResult.groundSojourn = struct();
    templateSingleModelResult.groundSojourn.totalGroundSojournTime = NaN;
    templateSingleModelResult.groundSojourn.meanGroundSojournTimeAcrossDays = NaN;
    templateSingleModelResult.groundSojourn.stdMeanGroundSojournTimeAcrossDays = NaN;
    templateSingleModelResult.groundSojourn.p95MeanGroundSojournTimeAcrossDays = NaN;
    templateSingleModelResult.groundSojourn.p99MeanGroundSojournTimeAcrossDays = NaN;
    templateSingleModelResult.groundSojourn.meanDailyP95GroundSojournTime = NaN;
    templateSingleModelResult.groundSojourn.p95DailyP95GroundSojournTime = NaN;
    templateSingleModelResult.groundSojourn.meanDailyP99GroundSojournTime = NaN;
    templateSingleModelResult.groundSojourn.maxDailyMaxGroundSojournTime = NaN;

    templateSingleModelResult.departureDelay = struct();
    templateSingleModelResult.departureDelay.totalDepartureDelay = NaN;
    templateSingleModelResult.departureDelay.totalPositiveDepartureDelay = NaN;
    templateSingleModelResult.departureDelay.meanPositiveDepartureDelayAcrossDays = NaN;
    templateSingleModelResult.departureDelay.stdMeanPositiveDepartureDelayAcrossDays = NaN;
    templateSingleModelResult.departureDelay.p90MeanPositiveDepartureDelayAcrossDays = NaN;
    templateSingleModelResult.departureDelay.p95MeanPositiveDepartureDelayAcrossDays = NaN;
    templateSingleModelResult.departureDelay.p99MeanPositiveDepartureDelayAcrossDays = NaN;
    templateSingleModelResult.departureDelay.maxMeanPositiveDepartureDelayAcrossDays = NaN;
    templateSingleModelResult.departureDelay.meanDailyP90PositiveDepartureDelay = NaN;
    templateSingleModelResult.departureDelay.meanDailyP95PositiveDepartureDelay = NaN;
    templateSingleModelResult.departureDelay.p95DailyP95PositiveDepartureDelay = NaN;
    templateSingleModelResult.departureDelay.meanDailyP99PositiveDepartureDelay = NaN;
    templateSingleModelResult.departureDelay.maxDailyMaxPositiveDepartureDelay = NaN;
    templateSingleModelResult.departureDelay.totalDelayAboveD1 = NaN;
    templateSingleModelResult.departureDelay.totalDelayAboveD2 = NaN;
    templateSingleModelResult.departureDelay.totalDelayAboveD3 = NaN;

    templateSingleModelResult.cost = struct();
    templateSingleModelResult.cost.totalDelayCost = NaN;
    templateSingleModelResult.cost.totalFluidCost = NaN;
    templateSingleModelResult.cost.totalActivationCost = NaN;
    templateSingleModelResult.cost.totalOperatingCost = NaN;
    templateSingleModelResult.cost.meanDailyOperatingCost = NaN;
    templateSingleModelResult.cost.stdDailyOperatingCost = NaN;
    templateSingleModelResult.cost.minDailyOperatingCost = NaN;
    templateSingleModelResult.cost.p90DailyOperatingCost = NaN;
    templateSingleModelResult.cost.p95DailyOperatingCost = NaN;
    templateSingleModelResult.cost.p99DailyOperatingCost = NaN;
    templateSingleModelResult.cost.maxDailyOperatingCost = NaN;
    templateSingleModelResult.cost.numPositiveCostDays = NaN;

    templateSingleModelResult.diagnostics = struct();
    templateSingleModelResult.diagnostics.numMissingOperatingCostDays = NaN;
    templateSingleModelResult.diagnostics.numMissingVolumeDays = NaN;
    templateSingleModelResult.diagnostics.numIncompleteDESDays = NaN;
    templateSingleModelResult.diagnostics.numNonemptyTerminalCalendars = NaN;

    templateSingleModelResult.simulationPlan = struct();
end