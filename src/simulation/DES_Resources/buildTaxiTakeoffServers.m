function taxiTakeoffServers = buildTaxiTakeoffServers()
    
    templateTaxiTakeoffServer = buildTemplateServerStruct();
    numTaxiTakeoffServers = getNumberOfTaxiTakeoffServers();
    taxiTakeoffServers = repmat(templateTaxiTakeoffServer, numTaxiTakeoffServers, 1);

    for i = 1 : numTaxiTakeoffServers
        taxiTakeoffServers(i).id = i;
    end
end