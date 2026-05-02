function eventCalendar = initializeEventCalendar(initialEvents)
    % INITIALIZEEVENTCALENDAR Initializes event calendar from optional event array.

    if nargin < 1
        initialEvents = repmat(buildTemplateEventStruct(), 0, 1);
    end

    eventCalendar = struct();
    eventCalendar.events = sortEventsByTime(initialEvents);
    eventCalendar.isSorted = true;
end