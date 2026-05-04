function main()
    % MAIN Runs full pipeline workflow, building and executing experiment plan.
    plans = unpackSimulationParameterGrids();
    runAllSimulations(plans);

    
end