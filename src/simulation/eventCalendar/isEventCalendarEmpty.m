function isEmpty = isEventCalendarEmpty(eventCalendar)
    % ISEVENTCALENDAREMPTY Returns true if event calendar contains no events.

    isEmpty = isempty(eventCalendar.events);
end