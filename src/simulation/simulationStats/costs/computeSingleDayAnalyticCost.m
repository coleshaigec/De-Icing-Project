% function dayCost = computeSingleDayAnalyticCost(analyticApprox, dayStorm, costModel)
%     % COMPUTESINGLEDAYANALYTICCOST Computes operating cost for one analytic storm-day approximation.
% 
%     arguments
%         analyticApprox (1, 1) struct
%         dayStorm (1, 1) struct
%         costModel (1, 1) struct
%     end
% 
%     delayCosts = costModel.delayCosts;
% 
%     delayCost = ...
%         delayCosts(1) * analyticApprox.departureDelay.totalDelayAboveD1 + ...
%         delayCosts(2) * analyticApprox.departureDelay.totalDelayAboveD2 + ...
%         delayCosts(3) * analyticApprox.departureDelay.totalDelayAboveD3;
% 
%     expectedTotalDeicingServiceTime = ...
%         analyticApprox.volume.expectedDeicingJobs ...
%         * analyticApprox.deicing.meanServiceTime;
% 
%     fluidCost = costModel.baseFluidCost ...
%         * expectedTotalDeicingServiceTime ...
%         * dayStorm.severity;
% 
%     activationCost = costModel.baseActivationCost;
% 
%     totalOperatingCost = delayCost + fluidCost + activationCost;
% 
%     dayCost = struct();
%     dayCost.scenarioName = costModel.scenarioName;
%     dayCost.delayCost = delayCost;
%     dayCost.fluidCost = fluidCost;
%     dayCost.activationCost = activationCost;
%     dayCost.totalOperatingCost = totalOperatingCost;
% end

function dayCost = computeSingleDayAnalyticCost(analyticApprox, dayStorm, costModel)
    % COMPUTESINGLEDAYANALYTICCOST Computes operating cost for one analytic storm-day approximation.
    %
    % NOTES
    %  The analytic approximation has no aircraft-level cancellation process.
    %  Cancellation cost is therefore explicitly reported as zero rather than
    %  silently omitted. This keeps analytic/DES comparisons honest: analytic
    %  total cost should primarily be compared to DES non-cancellation cost,
    %  not DES total cost including cancellations.

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
    cancellationCost = 0;

    nonCancellationOperatingCost = delayCost + fluidCost + activationCost;
    totalOperatingCost = nonCancellationOperatingCost + cancellationCost;

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
end

function share = safeCostShare(componentCost, totalCost)
    if totalCost == 0
        share = NaN;
    else
        share = componentCost / totalCost;
    end
end
