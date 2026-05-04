function dayCost = computeSingleDayDESCost(singleDayStats, costModel)
    % COMPUTESINGLEDAYDESCOST Computes operating cost for one simulated DES storm day.

    arguments
        singleDayStats (1, 1) struct
        costModel (1, 1) struct
    end

    delayCosts = costModel.delayCosts;

    delayCost = ...
        delayCosts(1) * singleDayStats.departureDelay.totalDelayAboveD1 + ...
        delayCosts(2) * singleDayStats.departureDelay.totalDelayAboveD2 + ...
        delayCosts(3) * singleDayStats.departureDelay.totalDelayAboveD3;

    fluidCost = costModel.baseFluidCost ...
        * singleDayStats.deicing.totalServiceTime ...
        * singleDayStats.storm.severity;

    activationCost = costModel.baseActivationCost;

    totalOperatingCost = delayCost + fluidCost + activationCost;

    dayCost = struct();
    dayCost.scenarioName = costModel.scenarioName;
    dayCost.delayCost = delayCost;
    dayCost.fluidCost = fluidCost;
    dayCost.activationCost = activationCost;
    dayCost.totalOperatingCost = totalOperatingCost;
end