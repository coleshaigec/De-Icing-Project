function [currentEvent, eventCalendar] = popNextEventFromCalendar(eventCalendar)

    assert(isfield(eventCalendar, "events"), ...
        "eventCalendar must contain events field.");

    assert(~isempty(eventCalendar.events), ...
        "Cannot pop event from empty event calendar.");

    if ~eventCalendar.isSorted
        [~, sortIdx] = sort([eventCalendar.events.time]);
        eventCalendar.events = eventCalendar.events(sortIdx);
        eventCalendar.isSorted = true;
    end

    currentEvent = eventCalendar.events(1);

    assert(isscalar(currentEvent), ...
        "Popped currentEvent must be scalar.");

    eventCalendar.events(1) = [];

    assert(isscalar(currentEvent.type) || ischar(currentEvent.type), ...
        sprintf("Popped currentEvent.type must be scalar string or char vector but got %s.", currentEvent.type));
end