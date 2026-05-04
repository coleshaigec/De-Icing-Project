function simContext = scheduleHOTViolatorArrival(simContext, aircraftID, startTime)
    % SCHEDULEHOTVIOLATORARRIVAL Schedules de-icing arrival event for HOT violator.
    %
    % NOTES
    % - It is assumed that HOT violators balk from taxi/takeoff after
    % having traversed the apron, meaning that they must taxi back to
    % de-icing
    % - Taxi dominates taxi/takeoff sojourn times in practice, so the
    % return taxi to de-icing is assumed to have the same service time
    % distribution (without queueing) as de-icing -> takeoff

    % -- Sample return taxi time for HOT violator --
    meanReturnTaxiServiceTime = simContext.taxiTakeoffProcess.T0;
    returnTaxiServiceTimeCV = simContext.taxiTakeoffProcess.CT;
    
    returnTaxiServiceTimeAlpha = 1 / returnTaxiServiceTimeCV^2;
    returnTaxiServiceTimeTheta = meanReturnTaxiServiceTime / returnTaxiServiceTimeAlpha;
    
    returnTaxiServiceTimeSample = gamrnd(returnTaxiServiceTimeAlpha, returnTaxiServiceTimeTheta);

    % -- Schedule arrival event and add to event calendar --
    hotViolatorArrivalEvent = buildTemplateEventStruct();
    hotViolatorArrivalEvent.time = startTime + returnTaxiServiceTimeSample;
    hotViolatorArrivalEvent.aircraftID = aircraftID;
    hotViolatorArrivalEvent.type = "hotViolatorArrival";
    simContext.eventCalendar = pushEventToCalendar(simContext.eventCalendar, hotViolatorArrivalEvent);
end