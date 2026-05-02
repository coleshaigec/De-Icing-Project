function stateTracker = pushAircraftToState(stateTracker, newAircraft)
% PUSHAIRCRAFTTOSTATE Adds one aircraft struct to the state tracker.
%
% INPUTS
%  stateTracker struct with fields
%      .aircraft (Nx1 struct array)
%  newAircraft struct
%
% OUTPUT
%  stateTracker updated with new aircraft appended
%
% INVARIANTS
%  - newAircraft must match aircraft struct schema
%  - aircraft array must remain column vector (Nx1)

    % -----------------------------
    % Preconditions / validation
    % -----------------------------

    % Ensure aircraft field exists
    assert(isfield(stateTracker, 'aircraft'), ...
        'stateTracker must contain field "aircraft".');

    % Enforce struct type
    assert(isstruct(newAircraft), ...
        'newAircraft must be a struct.');

    % Enforce schema consistency if non-empty
    if ~isempty(stateTracker.aircraft)
        existingFields = fieldnames(stateTracker.aircraft);
        newFields = fieldnames(newAircraft);

        assert(isequal(sort(existingFields), sort(newFields)), ...
            'newAircraft schema does not match existing aircraft struct.');
    end

    % -----------------------------
    % Append (column-safe)
    % -----------------------------

    stateTracker.aircraft(end + 1, 1) = newAircraft;

end