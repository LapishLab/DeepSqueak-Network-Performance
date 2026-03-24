function calls = filter_calls(calls, opts)
    arguments
        calls table %
        opts.min_duration double = .005 % minimum duration of a USV to be included in the analysis
        opts.min_score double = 0.5 % Score (confidence) of a USV to be included in the analysis
        opts.include_rejected logical = false; % Should USVs marked as "rejected" be included in the analysis
        opts.min_freq double = 18; % minimum frequency allowed for box
        opts.max_freq double = 100; % maxiumum frequency allowed for box
        opts.include_non_usv logical = false; % Should calls with labels other than USV be included?
    end

    % perform various checks
    calls = calls(calls.Box(:,3) > opts.min_duration, :);
    calls = calls(calls.Score > opts.min_score, :);
    calls = calls(calls.Box(:,2) > opts.min_freq, :);
    calls = calls(calls.Box(:,2)+calls.Box(:,4) < opts.max_freq, :);
    % calls = calculate_intensity(calls, detection.audiodata)

    % Only keep accepted calls
    if ~opts.include_rejected
        calls = calls(calls.Accept==1, :);
    end
    if ~opts.include_non_usv
        calls = calls(startsWith(string(calls.Type), "USV"), :);
    end
end