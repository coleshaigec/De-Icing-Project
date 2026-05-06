% function dayCost = computeSingleDayDESCost(singleDayStats, costModel)
%     % COMPUTESINGLEDAYDESCOST Computes operating cost for one simulated DES storm day.
% 
%     arguments
%         singleDayStats (1, 1) struct
%         costModel (1, 1) struct
%     end
% 
%     delayCosts = costModel.delayCosts;
% 
%     delayCost = ...
%         delayCosts(1) * singleDayStats.departureDelay.totalDelayAboveD1 + ...
%         delayCosts(2) * singleDayStats.departureDelay.totalDelayAboveD2 + ...
%         delayCosts(3) * singleDayStats.departureDelay.totalDelayAboveD3;
% 
%     fluidCost = costModel.baseFluidCost ...
%         * singleDayStats.deicing.totalServiceTime ...
%         * singleDayStats.storm.severity;
% 
%     activationCost = costModel.baseActivationCost;
% 
%     cancellationCost = ...
%         costModel.cancellationCost ...
%         * singleDayStats.cancellation.numCancellations;
% 
%     totalOperatingCost = ...
%         delayCost ...
%         + fluidCost ...
%         + activationCost ...
%         + cancellationCost;
% 
%     dayCost = struct();
%     dayCost.scenarioName = costModel.scenarioName;
% 
%     dayCost.delayCost = delayCost;
%     dayCost.fluidCost = fluidCost;
%     dayCost.activationCost = activationCost;
%     dayCost.cancellationCost = cancellationCost;
% 
%     dayCost.totalOperatingCost = totalOperatingCost;
% end

function dayCost = computeSingleDayDESCost(singleDayStats, costModel)
    % COMPUTESINGLEDAYDESCOST Computes operating cost for one simulated DES storm day.
    %
    % NOTES
    %  The total operating cost is reported both with and without cancellation
    %  penalties. This is intentional: cancellations are an operational failure
    %  metric and a tail-risk cost, while delay, fluid, and activation costs are
    %  recurring operating-cost components. Keeping both views prevents
    %  cancellation-heavy scenarios from masking the underlying service/capacity
    %  tradeoffs.

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

    cancellationCost = ...
        costModel.cancellationCost ...
        * singleDayStats.cancellation.numCancellations;

    nonCancellationOperatingCost = ...
        delayCost ...
        + fluidCost ...
        + activationCost;

    totalOperatingCost = ...
        nonCancellationOperatingCost ...
        + cancellationCost;

    dayCost = struct();
    dayCost.scenarioName = costModel.scenarioName;

    dayCost.delayCost = delayCost;
    dayCost.fluidCost = fluidCost;
    dayCost.activationCost = activationCost;
    dayCost.cancellationCost = cancellationCost;

    dayCost.nonCancellationOperatingCost = nonCancellationOperatingCost;
    dayCost.totalOperatingCost = totalOperatingCost;
    dayCost.totalOperatingCostIncludingCancellation = totalOperatingCost;

    dayCost.delayCostShare = safeCostShare(delayCost, totalOperatingCost);
    dayCost.fluidCostShare = safeCostShare(fluidCost, totalOperatingCost);
    dayCost.activationCostShare = safeCostShare(activationCost, totalOperatingCost);
    dayCost.cancellationCostShare = safeCostShare(cancellationCost, totalOperatingCost);

    dayCost.delayShareOfNonCancellationCost = ...
        safeCostShare(delayCost, nonCancellationOperatingCost);
    dayCost.fluidShareOfNonCancellationCost = ...
        safeCostShare(fluidCost, nonCancellationOperatingCost);
    dayCost.activationShareOfNonCancellationCost = ...
        safeCostShare(activationCost, nonCancellationOperatingCost);
end

function share = safeCostShare(componentCost, totalCost)
    if totalCost == 0
        share = NaN;
    else
        share = componentCost / totalCost;
    end
end
