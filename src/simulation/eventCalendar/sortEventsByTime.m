function sortedEvents = sortEventsByTime(events)
    % SORTEVENTSBYTIME Sorts event struct array by event time.

    if isempty(events)
        sortedEvents = events;
        return;
    end

    [~, sortIndices] = sort([events.time]);
    sortedEvents = events(sortIndices);
end