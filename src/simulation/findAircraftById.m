function [idx, aircraft] = findAircraftById(stateTracker, aircraftId)
% FINDAIRCRAFTBYID Returns index and struct of aircraft with given ID.
%
% OUTPUT
%  idx       index in stateTracker.aircraft (empty if not found)
%  aircraft  aircraft struct (empty if not found)

    % Preconditions
    assert(isfield(stateTracker, 'aircraft'), ...
        'stateTracker must contain aircraft field.');

    assert(isscalar(aircraftId) && isnumeric(aircraftId), ...
        'aircraftId must be a numeric scalar.');

    % Empty case
    if isempty(stateTracker.aircraft)
        idx = [];
        aircraft = [];
        return;
    end

    % Extract IDs (vectorized)
    allIds = [stateTracker.aircraft.id];

    % Find match
    idx = find(allIds == aircraftId, 1, 'first');

    assert(~isempty(idx), ...
    'findAircraftById:NotFound', ...
    'Aircraft ID %d not found.', aircraftId);

    aircraft = stateTracker.aircraft(idx);

end