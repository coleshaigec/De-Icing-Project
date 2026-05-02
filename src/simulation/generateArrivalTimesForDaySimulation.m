function arrivalTimes = generateArrivalTimesForDaySimulation(arrivalProcess, stormDurationHours)
    % GENERATEARRIVALTIMESFORDAYSIMULATION Generates samples of arrival process timestamps for day-level simulation.
    %
    % INPUTS 
    %  arrivalProcess struct with fields
    %      .scenarioName (string)                  - name of chosen arrival process scenario
    %      .lambdaBase (nonnegative double)        - baseline arrival rate
    %      .lambdaPeak (nonnegative double)        - peak arrival rate (per minute)
    %      .t0 (positive integer)                  - arrival pulse peak time
    %      .sigmaLambda (nonnegative double)       - arrival pulse tapering coefficient
    %      .Ca (nonnegative double)                - arrival process coefficient of variation
    %
    %  stormDurationHours (positive double)
    %
    % OUTPUTS
    %  arrivalTimes (numArrivals x 1 double)       - arrival timestamps, in minutes
    %
    % NOTES
    % - This function uses Lewis-Shedler thining 

    validateattributes(stormDurationHours, {'numeric'}, {'scalar', 'positive', 'finite'});

    simulationHorizonMinutes = 60.0 * stormDurationHours;

    lambdaMax = arrivalProcess.lambdaBase + arrivalProcess.lambdaPeak;

    if lambdaMax == 0
        arrivalTimes = zeros(0, 1);
        return;
    end

    candidateArrivalTimes = generateHomogeneousPoissonCandidateTimes( ...
        lambdaMax, simulationHorizonMinutes);

    lambdaAtCandidates = evaluateArrivalIntensity( ...
        candidateArrivalTimes, arrivalProcess);

    acceptanceProbabilities = lambdaAtCandidates ./ lambdaMax;

    acceptedMask = rand(size(candidateArrivalTimes)) <= acceptanceProbabilities;

    arrivalTimes = candidateArrivalTimes(acceptedMask);
    arrivalTimes = arrivalTimes(:);
end


function candidateArrivalTimes = generateHomogeneousPoissonCandidateTimes(lambdaRate, horizonMinutes)
    candidateArrivalTimes = zeros(0, 1);

    currentTime = 0.0;

    while true
        interarrivalTime = exprnd(1.0 / lambdaRate);
        currentTime = currentTime + interarrivalTime;

        if currentTime > horizonMinutes
            break;
        end

        candidateArrivalTimes(end + 1, 1) = currentTime; %#ok<AGROW>
    end
end


function lambdaValues = evaluateArrivalIntensity(tValues, arrivalProcess)
    lambdaValues = arrivalProcess.lambdaBase + arrivalProcess.lambdaPeak .* exp( ...
        -((tValues - arrivalProcess.t0).^2) ./ (2.0 * arrivalProcess.sigmaLambda.^2));
end