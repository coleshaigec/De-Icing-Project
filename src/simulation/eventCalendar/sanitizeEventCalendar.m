function eventCalendar = sanitizeEventCalendar(eventCalendar)
    % SANITIZEEVENTCALENDAR Removes invalid/template events from calendar.
    %
    % TEMPORARY DEBUG PATCH:
    %  Drops events with invalid time, empty type, invalid aircraftID, or invalid serverID shape.

    if isempty(eventCalendar.events)
        eventCalendar.events = repmat(buildTemplateEventStruct(), 0, 1);
        eventCalendar.isSorted = true;
        return;
    end

    events = eventCalendar.events(:);

    validMask = true(numel(events), 1);

    for i = 1:numel(events)
        thisEvent = events(i);

        hasValidTime = isfield(thisEvent, "time") && ...
            isscalar(thisEvent.time) && isfinite(thisEvent.time);

        hasValidType = isfield(thisEvent, "type") && ...
            ((isstring(thisEvent.type) && isscalar(thisEvent.type) && strlength(thisEvent.type) > 0) || ...
             (ischar(thisEvent.type) && ~isempty(thisEvent.type)));

        hasValidAircraftID = isfield(thisEvent, "aircraftID") && ...
            isscalar(thisEvent.aircraftID) && isfinite(thisEvent.aircraftID) && thisEvent.aircraftID > 0;

        hasValidServerID = isfield(thisEvent, "serverID") && ...
            isscalar(thisEvent.serverID) && ...
            (isnan(thisEvent.serverID) || (isfinite(thisEvent.serverID) && thisEvent.serverID > 0));

        validMask(i) = hasValidTime && hasValidType && hasValidAircraftID && hasValidServerID;
    end

    % if any(~validMask)
    %     fprintf(2, 'WARNING: Removed %d invalid/template events from event calendar.\n', nnz(~validMask));
    % end

    eventCalendar.events = events(validMask);
    eventCalendar.isSorted = false;
end