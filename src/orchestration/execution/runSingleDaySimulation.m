function singleDaySimulationResult = runSingleDaySimulation(yearSimulationPlan, stormIndex)
    % RUNSINGLEDAYSIMULATION Executes core DES logic for single storm day.
    %
    % INPUTS
    %  yearSimulationPlan struct with fields
    %      .policy struct with fields
    %          .k (positive integer)                   - number of de-icing pads
    %          .e (integer in [1,3])                   - chosen service process scenario
    %
    %      .arrivalProcess struct with fields
    %          .scenarioName (string)                  - name of chosen arrival process scenario
    %          .lambdaBase (nonnegative double)        - baseline arrival rate
    %          .lambdaPeak (nonnegative double)        - peak arrival rate (per minute)
    %          .t0 (positive integer)                  - arrival pulse peak time
    %          .sigmaLambda (nonnegative double)       - arrival pulse tapering coefficient
    %          .Ca (nonnegative double)                - arrival process coefficient of variation
    %
    %      .serviceProcess struct with fields
    %          .scenarioName (string)                  - name of chosen service process scenario
    %          .muDI (nonnegative double)              - scenario-specific de-icing service rate
    %          .eta (nonnegative double)               - de-icing -> taxi/takeoff congestion propagation parameter
    %          .Cs (nonnegative double)                - de-icing process coefficient of variation
    %          .activationCostMultiple (double)        - scenario-specific resource activation cost multiplier
    %          .serviceProcessCAPEXCase (string)       - "low", "medium", or "high"
    %
    %      .taxiTakeoffProcess struct with fields
    %          .scenarioName (string)                  - name of chosen taxi/takeoff process scenario
    %          .beta (double)                          - taxi/takeoff sojourn time congestion scaling parameter
    %          .p (double)                             - taxi/takeoff sojourn time congestion explosion parameter
    %          .T0 (double)                            - baseline zero-congestion taxi/takeoff sojourn time
    %          .CT (nonnegative double)                - taxi/takeoff process coefficient of variation
    %
    %      .annualNumberOfStorms (positive integer)   - number of storm-day events simulated for the year
    %      .stormDistributionParameters struct        - global parameters used to generate storm events
    %      .stormEvents array of structs, each with fields
    %          .eventIndex (positive integer)             - index of storm event within the annual scenario
    %          .severity (nonnegative double)             - sampled latent storm severity
    %          .durationHours (positive double)           - storm duration in hours
    %          .fluidCostMultiple (positive double)       - storm-specific fluid cost multiplier
    %          .activationCostMultiple (positive double)  - storm-specific activation cost multiplier
    %
    %      .costModel struct with fields
    %          .scenarioName (string)                  - name of chosen cost scenario
    %          .singlePadCAPEX (nonnegative double)    - initial capital outlay to build a single pad
    %          .serviceProcessCAPEXes (double array)   - initial capital outlay for equipment and other inputs in each service process scenario
    %          .delayCosts (double array)              - escalating piecewise linear delay cost terms [CD1, CD2, CD3]
    %          .baseFluidCost (double)                 - base fluid cost
    %          .baseActivationCost (double)            - base resource activation cost 
    %
    %  stormIndex (integer)  - used to extract day's storm conditions from year-level plan
    %
    % OUTPUT
    %  singleDaySimulationResult struct with fields

    % ===============
    % Initialization
    % ===============

    % -- Extract storm scenario --
    dayStorm = yearSimulationPlan.stormEvents(stormIndex);

    % -- Generate external arrival process --
    arrivalTimestamps = generateArrivalTimesForDaySimulation(yearSimulationPlan.arrivalProcess, dayStorm.durationHours);
    externalArrivalEvents = buildAircraftArrivalEventsFromTimestamps(arrivalTimestamps);

    % -- Build de-icing servers --
    deicingServers = buildDeicingServers()


    eventCalendar = initializeEventCalendar(externalArrivalEvents);

    simContext = struct();
    simContext.eventCalendar = eventCalendar;
    simContext.clock = 0;
    simContext.state = buildTemplateStateStruct();
    simContext.aircraft = [];
    simContext.storm = dayStorm;
    simContext.deicingServers = 

    % ================
    % Core event loop
    % ================
    while ~isEventCalendarEmpty(simContext.eventCalendar)
        [currentEvent, simContext.eventCalendar] = popNextEventFromCalendar( ...
            simContext.eventCalendar);
    
        simContext.clock = currentEvent.time;
        simContext = handleEvent(simContext, currentEvent);
    end


end