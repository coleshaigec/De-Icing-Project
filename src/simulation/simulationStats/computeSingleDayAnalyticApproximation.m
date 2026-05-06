% function analyticApprox = computeSingleDayAnalyticApproximation( ...
%     yearSimulationPlan, dayStorm, delayCostThresholds, costModel)
%     % COMPUTESINGLEDAYANALYTICAPPROXIMATION Computes PSA-based analytic model predictions.
%     %
%     % DESIGN NOTES
%     % - Fully vectorized, no per-aircraft logic
%     % - Uses fixed small number of fixed-point iterations (3)
%     % - Uses coarse time grid (dt = 2 minutes) for speed
%     % - MMPP-ready: arrival intensity evaluated via function
% 
%     % =========================
%     % Parameter extraction
%     % =========================
%     arrivalProcess = yearSimulationPlan.arrivalProcess;
%     serviceProcess = yearSimulationPlan.serviceProcess;
%     taxiProcess = yearSimulationPlan.taxiTakeoffProcess;
%     policy = yearSimulationPlan.policy;
% 
%     k = policy.k;
% 
%     % De-icing parameters
%     muDI = serviceProcess.muDI;
%     E_S_DI = 1 / muDI;
%     Cs = serviceProcess.Cs;
%     Ca = arrivalProcess.Ca;
%     eta = serviceProcess.eta;
% 
%     % Taxi/takeoff parameters
%     T0 = taxiProcess.T0;
%     beta = taxiProcess.beta;
%     p = taxiProcess.p;
%     CT = taxiProcess.CT;
% 
%     % HOT threshold (fixed scalar for speed)
%     T_star = 60;  
% 
%     % =========================
%     % Time grid
%     % =========================
%     horizonMinutes = 60 * dayStorm.durationHours;
%     dt = 2;
%     t = (0:dt:horizonMinutes)';
% 
%     % =========================
%     % External arrival rate λ(t)
%     % =========================
%     lambdaExt = evaluateArrivalIntensity(t, arrivalProcess);
% 
%     % =========================
%     % Fixed-point solve for λ_eff
%     % =========================
%     lambdaEff = lambdaExt;
% 
%     for iter = 1:3
%         % Utilization
%         rhoDI = (lambdaEff .* E_S_DI) ./ k;
%         rhoDI = min(rhoDI, 0.99);
% 
%         % Taxi congestion proxy
%         alphaDI = 1 + eta .* rhoDI;
% 
%         muTT = 1 / T0;
%         rhoTT = lambdaEff ./ muTT;
% 
%         chi = rhoTT .* alphaDI;
% 
%         % Expected taxi time
%         E_TT = T0 + beta .* (chi .^ p);
% 
%         % Gamma params
%         alphaTT = 1 / (CT^2);
%         thetaTT = (CT^2) .* E_TT;
% 
%         % HOT violation probability
%         q = 1 - gamcdf(T_star, alphaTT, thetaTT);
% 
%         % Fixed-point update
%         lambdaEff = lambdaExt ./ (1 - q);
%     end
% 
%     % =========================
%     % De-icing queue delay (Sakasegawa)
%     % =========================
%     rhoDI = (lambdaEff .* E_S_DI) ./ k;
%     rhoDI = min(rhoDI, 0.99);
% 
%     exponent = sqrt(2*(k+1)) - 1;
% 
%     EWq = (rhoDI.^exponent ./ (k .* (1 - rhoDI))) .* ...
%           ((Ca^2 + Cs^2)/2) .* E_S_DI;
% 
%     % =========================
%     % Recompute final quantities
%     % =========================
%     alphaDI = 1 + eta .* rhoDI;
%     muTT = 1 / T0;
%     rhoTT = lambdaEff ./ muTT;
%     chi = rhoTT .* alphaDI;
% 
%     E_TT = T0 + beta .* (chi .^ p);
% 
%     alphaTT = 1 / (CT^2);
%     thetaTT = (CT^2) .* E_TT;
% 
%     q = 1 - gamcdf(T_star, alphaTT, thetaTT);
% 
%     % =========================
%     % Aggregation (PSA integrals)
%     % =========================
%     totalExternalArrivals = trapz(t, lambdaExt);
%     totalDeicingJobs = trapz(t, lambdaEff);
%     totalHOTViolations = trapz(t, lambdaEff .* q);
% 
%     q_bar = totalHOTViolations / totalDeicingJobs;
% 
%     meanEWq = trapz(t, lambdaEff .* EWq) / totalDeicingJobs;
%     meanETT = trapz(t, lambdaEff .* E_TT) / totalDeicingJobs;
% 
%     % Ground sojourn (from PDF)
%     meanGroundSojourn = (1 / (1 - q_bar)) * ...
%         (meanEWq + E_S_DI) + meanETT;
% 
%     % =========================
%     % Delay proxy (very rough)
%     % =========================
%     allowableBaseline = getAllowableBaselineGroundSojournTime();
%     delay = max(meanGroundSojourn - allowableBaseline, 0);
% 
%     d1 = delayCostThresholds(1);
%     d2 = delayCostThresholds(2);
%     d3 = delayCostThresholds(3);
% 
%     % =========================
%     % Build output struct
%     % =========================
%     analyticApprox = struct();
% 
%     % ---- Volume ----
%     analyticApprox.volume = struct();
%     analyticApprox.volume.expectedExternalArrivals = totalExternalArrivals;
%     analyticApprox.volume.expectedDeicingJobs = totalDeicingJobs;
%     analyticApprox.volume.expectedHOTViolations = totalHOTViolations;
%     analyticApprox.volume.expectedDeicingJobsPerExternalAircraft = ...
%         totalDeicingJobs / totalExternalArrivals;
%     analyticApprox.volume.meanHOTViolationProbability = q_bar;
% 
%     % ---- Deicing ----
%     analyticApprox.deicing = struct();
%     analyticApprox.deicing.meanQueueingDelay = meanEWq;
%     analyticApprox.deicing.meanServiceTime = E_S_DI;
% 
%     % ---- Taxi/Takeoff ----
%     analyticApprox.taxiTakeoff = struct();
%     analyticApprox.taxiTakeoff.meanSojournTime = meanETT;
% 
%     % ---- Ground Sojourn ----
%     analyticApprox.groundSojourn = struct();
%     analyticApprox.groundSojourn.meanGroundSojournTime = meanGroundSojourn;
% 
%     % ---- Delay ----
%     analyticApprox.departureDelay = struct();
%     analyticApprox.departureDelay.meanPositiveDelayProxy = delay;
%     analyticApprox.departureDelay.totalDelayAboveD1 = max(delay - d1, 0);
%     analyticApprox.departureDelay.totalDelayAboveD2 = max(delay - d2, 0);
%     analyticApprox.departureDelay.totalDelayAboveD3 = max(delay - d3, 0);
% 
%     % ---- Time series (lightweight) ----
%     analyticApprox.timeSeries = struct();
%     analyticApprox.timeSeries.t = t;
%     analyticApprox.timeSeries.lambdaExt = lambdaExt;
%     analyticApprox.timeSeries.lambdaEff = lambdaEff;
%     analyticApprox.timeSeries.rhoDI = rhoDI;
%     analyticApprox.timeSeries.qHOT = q;
%     analyticApprox.timeSeries.E_TT = E_TT;
% 
%     % -- Cost --
%     analyticApprox.cost = computeSingleDayAnalyticCost(analyticApprox, dayStorm, costModel);
% 
% end

function analyticApprox = computeSingleDayAnalyticApproximation( ...
    yearSimulationPlan, dayStorm, delayCostThresholds, costModel)
    % COMPUTESINGLEDAYANALYTICAPPROXIMATION Computes PSA-based analytic model predictions.
    %
    % DESIGN NOTES
    % - Fully vectorized, no per-aircraft logic
    % - Uses fixed small number of fixed-point iterations (3)
    % - Uses coarse time grid (dt = 2 minutes) for speed
    % - MMPP-ready: arrival intensity evaluated via function
    %
    % COMPARABILITY NOTE
    %  The analytic model produces first-moment approximations. It does not
    %  simulate aircraft-level departure delays or cancellations. Therefore,
    %  delay-cost quantities below convert the representative positive delay
    %  proxy into an expected aggregate delay by multiplying by expected
    %  external arrivals. This is still an approximation, but it is at least on
    %  the same aggregate scale as the DES cost function.

    arguments
        yearSimulationPlan (1, 1) struct
        dayStorm (1, 1) struct
        delayCostThresholds (1, 3) double {mustBeNonnegative, mustBeFinite}
        costModel (1, 1) struct
    end

    % =========================
    % Parameter extraction
    % =========================
    arrivalProcess = yearSimulationPlan.arrivalProcess;
    serviceProcess = yearSimulationPlan.serviceProcess;
    taxiProcess = yearSimulationPlan.taxiTakeoffProcess;
    policy = yearSimulationPlan.policy;

    k = policy.k;

    % De-icing parameters
    muDI = serviceProcess.muDI;
    E_S_DI = 1 / muDI;
    Cs = serviceProcess.Cs;
    Ca = arrivalProcess.Ca;
    eta = serviceProcess.eta;

    % Taxi/takeoff parameters
    T0 = taxiProcess.T0;
    beta = taxiProcess.beta;
    p = taxiProcess.p;
    CT = taxiProcess.CT;

    % HOT threshold (fixed scalar for speed)
    T_star = 60;

    % =========================
    % Time grid
    % =========================
    horizonMinutes = 60 * dayStorm.durationHours;
    dt = 2;
    t = (0:dt:horizonMinutes)';

    % =========================
    % External arrival rate lambda(t)
    % =========================
    lambdaExt = evaluateArrivalIntensity(t, arrivalProcess);

    % =========================
    % Fixed-point solve for lambda_eff
    % =========================
    lambdaEff = lambdaExt;

    for iter = 1:3 %#ok<NASGU>
        rhoDI = (lambdaEff .* E_S_DI) ./ k;
        rhoDI = min(rhoDI, 0.99);

        alphaDI = 1 + eta .* rhoDI;

        muTT = 1 / T0;
        rhoTT = lambdaEff ./ muTT;

        chi = rhoTT .* alphaDI;
        E_TT = T0 + beta .* (chi .^ p);

        alphaTT = 1 / (CT^2);
        thetaTT = (CT^2) .* E_TT;

        q = 1 - gamcdf(T_star, alphaTT, thetaTT);
        q = min(max(q, 0), 0.95);

        lambdaEff = lambdaExt ./ max(1 - q, eps);
    end

    % =========================
    % De-icing queue delay (Sakasegawa)
    % =========================
    rhoDI = (lambdaEff .* E_S_DI) ./ k;
    rhoDI = min(rhoDI, 0.99);

    exponent = sqrt(2 * (k + 1)) - 1;

    EWq = (rhoDI.^exponent ./ (k .* (1 - rhoDI))) .* ...
          ((Ca^2 + Cs^2) / 2) .* E_S_DI;

    % =========================
    % Recompute final quantities
    % =========================
    alphaDI = 1 + eta .* rhoDI;
    muTT = 1 / T0;
    rhoTT = lambdaEff ./ muTT;
    chi = rhoTT .* alphaDI;

    E_TT = T0 + beta .* (chi .^ p);

    alphaTT = 1 / (CT^2);
    thetaTT = (CT^2) .* E_TT;

    q = 1 - gamcdf(T_star, alphaTT, thetaTT);
    q = min(max(q, 0), 0.95);

    % =========================
    % Aggregation (PSA integrals)
    % =========================
    totalExternalArrivals = trapz(t, lambdaExt);
    totalDeicingJobs = trapz(t, lambdaEff);
    totalHOTViolations = trapz(t, lambdaEff .* q);

    q_bar = safeDivide(totalHOTViolations, totalDeicingJobs);

    meanEWq = safeDivide(trapz(t, lambdaEff .* EWq), totalDeicingJobs);
    meanETT = safeDivide(trapz(t, lambdaEff .* E_TT), totalDeicingJobs);

    % Ground sojourn approximation.
    meanGroundSojourn = (1 / max(1 - q_bar, eps)) * ...
        (meanEWq + E_S_DI) + meanETT;

    % =========================
    % Delay proxy
    % =========================
    allowableBaseline = getAllowableBaselineGroundSojournTime();
    representativePositiveDelay = max(meanGroundSojourn - allowableBaseline, 0);

    d1 = delayCostThresholds(1);
    d2 = delayCostThresholds(2);
    d3 = delayCostThresholds(3);

    % Aggregate-scale delay exceedance approximation. This fixes the old
    % scale error where threshold exceedance was a representative-aircraft
    % quantity but was consumed downstream as a total system quantity.
    totalDelayAboveD1 = totalExternalArrivals * max(representativePositiveDelay - d1, 0);
    totalDelayAboveD2 = totalExternalArrivals * max(representativePositiveDelay - d2, 0);
    totalDelayAboveD3 = totalExternalArrivals * max(representativePositiveDelay - d3, 0);

    % =========================
    % Build output struct
    % =========================
    analyticApprox = struct();

    analyticApprox.volume = struct();
    analyticApprox.volume.expectedExternalArrivals = totalExternalArrivals;
    analyticApprox.volume.expectedDeicingJobs = totalDeicingJobs;
    analyticApprox.volume.expectedHOTViolations = totalHOTViolations;
    analyticApprox.volume.expectedDeicingJobsPerExternalAircraft = ...
        safeDivide(totalDeicingJobs, totalExternalArrivals);
    analyticApprox.volume.meanHOTViolationProbability = q_bar;

    analyticApprox.deicing = struct();
    analyticApprox.deicing.meanQueueingDelay = meanEWq;
    analyticApprox.deicing.meanServiceTime = E_S_DI;

    analyticApprox.taxiTakeoff = struct();
    analyticApprox.taxiTakeoff.meanSojournTime = meanETT;

    analyticApprox.groundSojourn = struct();
    analyticApprox.groundSojourn.meanGroundSojournTime = meanGroundSojourn;

    analyticApprox.departureDelay = struct();
    analyticApprox.departureDelay.meanPositiveDelayProxy = representativePositiveDelay;
    analyticApprox.departureDelay.totalDelayAboveD1 = totalDelayAboveD1;
    analyticApprox.departureDelay.totalDelayAboveD2 = totalDelayAboveD2;
    analyticApprox.departureDelay.totalDelayAboveD3 = totalDelayAboveD3;

    analyticApprox.timeSeries = struct();
    analyticApprox.timeSeries.t = t;
    analyticApprox.timeSeries.lambdaExt = lambdaExt;
    analyticApprox.timeSeries.lambdaEff = lambdaEff;
    analyticApprox.timeSeries.rhoDI = rhoDI;
    analyticApprox.timeSeries.qHOT = q;
    analyticApprox.timeSeries.E_TT = E_TT;

    analyticApprox.cost = computeSingleDayAnalyticCost(analyticApprox, dayStorm, costModel);
end

function quotient = safeDivide(numerator, denominator)
    if denominator == 0
        quotient = NaN;
    else
        quotient = numerator / denominator;
    end
end
