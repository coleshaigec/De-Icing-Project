function stormEvents = buildStormEvents(annualNumberOfStorms, stormDistributionParameters)
    % BUILDSTORMEVENTS Builds stochastic day-level storm event structs for one annual simulation plan.
    %
    % INPUTS
    %  annualNumberOfStorms (positive integer)        - number of storm-day events simulated for the year
    %
    %  stormDistributionParameters struct with fields
    %      .alpha (positive double)                   - Gamma shape parameter for latent storm severity
    %      .theta (positive double)                   - Gamma scale parameter for latent storm severity
    %
    % OUTPUT
    %  stormEvents array of structs, each with fields
    %      .eventIndex (positive integer)             - index of storm event within the annual scenario
    %      .severity (nonnegative double)             - sampled latent storm severity
    %      .durationHours (positive double)           - storm duration in hours
    %      .fluidCostMultiple (positive double)       - storm-specific fluid cost multiplier
    %      .activationCostMultiple (positive double)  - storm-specific activation cost multiplier
    %
    % NOTES
    % - Storm severity is sampled from a Gamma distribution with positive
    %   support.
    % - The sampled severity is normalized by its mean so that severity has
    %   expected value 1. This makes the downstream mappings interpretable.
    % - Duration, fluid cost multiple, and activation cost multiple are all
    %   monotone functions of the same latent severity draw. This creates
    %   positive correlation among storm properties without requiring a full
    %   meteorological model.

    arguments
        annualNumberOfStorms (1, 1) double {mustBeInteger, mustBePositive}
        stormDistributionParameters (1, 1) struct
    end

    assert(isfield(stormDistributionParameters, 'alpha'), ...
        'stormDistributionParameters must contain field alpha.');

    assert(isfield(stormDistributionParameters, 'theta'), ...
        'stormDistributionParameters must contain field theta.');

    alpha = stormDistributionParameters.alpha;
    theta = stormDistributionParameters.theta;

    assert(isnumeric(alpha) && isscalar(alpha) && alpha > 0, ...
        'stormDistributionParameters.alpha must be a positive numeric scalar.');

    assert(isnumeric(theta) && isscalar(theta) && theta > 0, ...
        'stormDistributionParameters.theta must be a positive numeric scalar.');

    templateStormEventStruct = buildTemplateStormEventStruct();
    stormEvents = repmat(templateStormEventStruct, annualNumberOfStorms, 1);

    expectedSeverity = alpha * theta;

    baseDurationHours = 2;
    durationHoursPerMeanSeverity = 4;

    baseFluidCostMultiple = 1;
    fluidCostMultiplePerMeanSeverity = 1.5;

    baseActivationCostMultiple = 1;
    activationCostMultiplePerMeanSeverity = 1.0;

    for iStorm = 1:annualNumberOfStorms
        rawSeverity = gamrnd(alpha, theta);
        normalizedSeverity = rawSeverity / expectedSeverity;

        stormEvents(iStorm) = templateStormEventStruct;
        stormEvents(iStorm).eventIndex = iStorm;
        stormEvents(iStorm).severity = normalizedSeverity;

        stormEvents(iStorm).durationHours = ...
            baseDurationHours ...
            + durationHoursPerMeanSeverity * normalizedSeverity;

        stormEvents(iStorm).fluidCostMultiple = ...
            baseFluidCostMultiple ...
            + fluidCostMultiplePerMeanSeverity * normalizedSeverity;

        stormEvents(iStorm).activationCostMultiple = ...
            baseActivationCostMultiple ...
            + activationCostMultiplePerMeanSeverity * normalizedSeverity;
    end
end