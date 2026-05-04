function dayCost = computeSingleDayAnalyticCost(analyticApprox, dayStorm, costModel)
    % COMPUTESINGLEDAYANALYTICCOST Computes operating cost for one analytic storm-day approximation.

    arguments
        analyticApprox (1, 1) struct
        dayStorm (1, 1) struct
        costModel (1, 1) struct
    end

    delayCosts = costModel.delayCosts;

    delayCost = ...
        delayCosts(1) * analyticApprox.departureDelay.totalDelayAboveD1 + ...
        delayCosts(2) * analyticApprox.departureDelay.totalDelayAboveD2 + ...
        delayCosts(3) * analyticApprox.departureDelay.totalDelayAboveD3;

    expectedTotalDeicingServiceTime = ...
        analyticApprox.volume.expectedDeicingJobs ...
        * analyticApprox.deicing.meanServiceTime;

    fluidCost = costModel.baseFluidCost ...
        * expectedTotalDeicingServiceTime ...
        * dayStorm.severity;

    activationCost = costModel.baseActivationCost;

    totalOperatingCost = delayCost + fluidCost + activationCost;

    dayCost = struct();
    dayCost.scenarioName = costModel.scenarioName;
    dayCost.delayCost = delayCost;
    dayCost.fluidCost = fluidCost;
    dayCost.activationCost = activationCost;
    dayCost.totalOperatingCost = totalOperatingCost;
end