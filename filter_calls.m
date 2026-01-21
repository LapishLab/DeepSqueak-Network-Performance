function detection = filter_calls(detection, opts)
    arguments
        detection struct %
        opts.min_duration double = 0 % minimum duration of a USV to be included in the analysis
        opts.min_score double = 0 % Score (confidence) of a USV to be included in the analysis
        opts.include_rejected logical = false; % Should USVs marked as "rejected" be included in the analysis
        opts.min_freq double = 18; % minimum frequency allowed for box
        opts.max_freq double = 100; % maxiumum frequency allowed for box
    end

    calls = detection.Calls;
    % perform various checks
    calls = calls(calls.Box(:,3) > opts.min_duration, :);
    calls = calls(calls.Score > opts.min_score, :);
    calls = calls(calls.Box(:,2) > opts.min_freq, :);
    calls = calls(calls.Box(:,2)+calls.Box(:,4) < opts.max_freq, :);

    % Only keep accepted calls
    if ~opts.include_rejected
        calls = calls(calls.Accept==1, :);
    end

    detection.Calls = calls;
end