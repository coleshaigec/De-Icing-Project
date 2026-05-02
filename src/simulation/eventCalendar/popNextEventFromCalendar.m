function [nextEvent, eventCalendar] = popNextEventFromCalendar(eventCalendar)
    % POPNEXTEVENTFROMCALENDAR Removes and returns earliest event.

    if isempty(eventCalendar.events)
        error('popNextEventFromCalendar:EmptyCalendar', ...
            'Cannot pop from an empty event calendar.');
    end

    if ~eventCalendar.isSorted
        eventCalendar.events = sortEventsByTime(eventCalendar.events);
        eventCalendar.isSorted = true;
    end

    nextEvent = eventCalendar.events(1);
    eventCalendar.events = eventCalendar.events(2:end);
end