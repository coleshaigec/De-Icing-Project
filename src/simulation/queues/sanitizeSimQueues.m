function simContext = sanitizeSimQueues(simContext)
    % SANITIZESIMQUEUES Removes invalid placeholder aircraft IDs from live queues.
    %
    % TEMPORARY DEBUG PATCH:
    %  Removes nonpositive / nonfinite aircraft IDs from queue state.

    simContext.state.deicingQueue = sanitizeAircraftIDQueue( ...
        simContext.state.deicingQueue, "deicingQueue");

    simContext.state.taxiTakeoffQueue = sanitizeAircraftIDQueue( ...
        simContext.state.taxiTakeoffQueue, "taxiTakeoffQueue");
end

function queue = sanitizeAircraftIDQueue(queue, queueName)

    if isempty(queue)
        queue = zeros(0, 1);
        return;
    end

    queue = queue(:);

    validMask = isfinite(queue) & queue > 0;

    if any(~validMask)
        fprintf(2, ...
            'WARNING: Removed %d invalid aircraft IDs from %s: ', ...
            nnz(~validMask), queueName);
        fprintf(2, '%g ', queue(~validMask));
        fprintf(2, '\n');
    end

    queue = queue(validMask);
end