function lambdaValues = evaluateArrivalIntensity(tValues, arrivalProcess)
    lambdaValues = arrivalProcess.lambdaBase + arrivalProcess.lambdaPeak .* exp( ...
        -((tValues - arrivalProcess.t0).^2) ./ (2.0 * arrivalProcess.sigmaLambda.^2));
end