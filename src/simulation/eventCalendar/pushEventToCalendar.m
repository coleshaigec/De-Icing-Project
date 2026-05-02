function eventCalendar = pushEventToCalendar(eventCalendar, newEvent)
    % PUSHEVENTTOCALENDAR Adds one event to the event calendar.

    eventCalendar.events(end + 1, 1) = newEvent;
    eventCalendar.isSorted = false;
end