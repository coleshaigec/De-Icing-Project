function taxiTakeoffServers = buildTaxiTakeoffServers()
    % BUILDTAXITAKEOFFSERVERS Initializes taxi/takeoff server struct array for state tracking
    templateTaxiTakeoffServer = buildTemplateServerStruct();
    numTaxiTakeoffServers = getNumberOfTaxiTakeoffServers();
    taxiTakeoffServers = repmat(templateTaxiTakeoffServer, numTaxiTakeoffServers, 1);

    for i = 1 : numTaxiTakeoffServers
        taxiTakeoffServers(i).id = i;
    end
end