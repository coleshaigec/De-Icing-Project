function capexResults = runCAPEXSweep()
    % RUNCAPEXSWEEP Runs a broad deterministic CAPEX sensitivity sweep.
    %
    % This function builds a grid over policy variables and financial/cost
    % assumptions, computes initial CAPEX I(k,e), annualized CAPEX A(k,e),
    % and writes the resulting table to CSV.
    %
    % Outputs:
    %   capexResults - table containing all CAPEX sweep scenarios.

    grids = buildGridsForCAPEXSweep();

    nK = numel(grids.policyKValues);
    nE = numel(grids.policyEValues);
    nR = numel(grids.discountRateValues);
    nL = numel(grids.assetLifeValues);
    nFixed = numel(grids.fixedInfrastructureCostValues);
    nServer = numel(grids.serverCapitalCostValues);
    nService = numel(grids.serviceRateUpgradeCostValues);
    nCurvature = numel(grids.serviceRateCurvatureValues);

    nRows = nK * nE * nR * nL * nFixed * nServer * nService * nCurvature;

    policyK = zeros(nRows, 1);
    policyE = zeros(nRows, 1);
    discountRate = zeros(nRows, 1);
    assetLifeYears = zeros(nRows, 1);
    fixedInfrastructureCost = zeros(nRows, 1);
    serverCapitalCost = zeros(nRows, 1);
    serviceRateUpgradeCost = zeros(nRows, 1);
    serviceRateCurvature = zeros(nRows, 1);
    baselineServiceRate = zeros(nRows, 1);
    initialOutlay = zeros(nRows, 1);
    capitalRecoveryFactor = zeros(nRows, 1);
    annualizedCapex = zeros(nRows, 1);
    capexScenarioName = strings(nRows, 1);

    row = 0;

    for iK = 1:nK
        k = grids.policyKValues(iK);

        for iE = 1:nE
            e = grids.policyEValues(iE);

            for iR = 1:nR
                r = grids.discountRateValues(iR);

                for iL = 1:nL
                    L = grids.assetLifeValues(iL);

                    crf = computeCapitalRecoveryFactor(r, L);

                    for iFixed = 1:nFixed
                        fixedCost = grids.fixedInfrastructureCostValues(iFixed);

                        for iServer = 1:nServer
                            serverCost = grids.serverCapitalCostValues(iServer);

                            for iService = 1:nService
                                serviceUpgradeCost = grids.serviceRateUpgradeCostValues(iService);

                                for iCurvature = 1:nCurvature
                                    curvature = grids.serviceRateCurvatureValues(iCurvature);

                                    row = row + 1;

                                    serviceRateIncrement = max(e - grids.baselineServiceRate, 0);
                                    serviceUpgradeTerm = ...
                                        serviceUpgradeCost * k * serviceRateIncrement ^ curvature;

                                    outlay = fixedCost + serverCost * k + serviceUpgradeTerm;
                                    annualized = outlay * crf;

                                    policyK(row) = k;
                                    policyE(row) = e;
                                    discountRate(row) = r;
                                    assetLifeYears(row) = L;
                                    fixedInfrastructureCost(row) = fixedCost;
                                    serverCapitalCost(row) = serverCost;
                                    serviceRateUpgradeCost(row) = serviceUpgradeCost;
                                    serviceRateCurvature(row) = curvature;
                                    baselineServiceRate(row) = grids.baselineServiceRate;
                                    initialOutlay(row) = outlay;
                                    capitalRecoveryFactor(row) = crf;
                                    annualizedCapex(row) = annualized;

                                    capexScenarioName(row) = composeScenarioName( ...
                                        fixedCost, serverCost, serviceUpgradeCost, ...
                                        curvature, r, L);
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    assert(row == nRows, ...
        "runCAPEXSweep:RowCountMismatch", ...
        "Expected %d rows but populated %d rows.", nRows, row);

    capexResults = table( ...
        capexScenarioName, ...
        policyK, ...
        policyE, ...
        baselineServiceRate, ...
        fixedInfrastructureCost, ...
        serverCapitalCost, ...
        serviceRateUpgradeCost, ...
        serviceRateCurvature, ...
        initialOutlay, ...
        discountRate, ...
        assetLifeYears, ...
        capitalRecoveryFactor, ...
        annualizedCapex);

    writeCAPEXResultsToCSV(capexResults, grids.outputDirectory);
end

function crf = computeCapitalRecoveryFactor(discountRate, assetLifeYears)
    % COMPUTECAPITALRECOVERYFACTOR Computes the standard CRF.
    %
    % Inputs:
    %   discountRate    - scalar annual discount rate.
    %   assetLifeYears  - scalar useful life in years.
    %
    % Output:
    %   crf             - scalar capital recovery factor.

    assert(isscalar(discountRate) && isfinite(discountRate), ...
        "computeCapitalRecoveryFactor:InvalidDiscountRate", ...
        "discountRate must be a finite scalar.");

    assert(isscalar(assetLifeYears) && isfinite(assetLifeYears), ...
        "computeCapitalRecoveryFactor:InvalidAssetLife", ...
        "assetLifeYears must be a finite scalar.");

    assert(discountRate >= 0, ...
        "computeCapitalRecoveryFactor:NegativeDiscountRate", ...
        "discountRate must be nonnegative.");

    assert(assetLifeYears > 0, ...
        "computeCapitalRecoveryFactor:NonpositiveAssetLife", ...
        "assetLifeYears must be positive.");

    if discountRate == 0
        crf = 1 / assetLifeYears;
        return;
    end

    growthFactor = (1 + discountRate) ^ assetLifeYears;
    crf = discountRate * growthFactor / (growthFactor - 1);
end

function scenarioName = composeScenarioName( ...
        fixedCost, serverCost, serviceUpgradeCost, curvature, discountRate, assetLifeYears)
    % COMPOSESCENARIONAME Builds a readable CAPEX scenario label.

    scenarioName = sprintf( ...
        "fixed%.0f_server%.0f_service%.0f_curv%.2f_r%.3f_L%.0f", ...
        fixedCost, serverCost, serviceUpgradeCost, curvature, ...
        discountRate, assetLifeYears);
end