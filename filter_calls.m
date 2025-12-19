function calls = filter_calls(calls, opts)
    arguments
        calls table %
        opts.min_duration double = 0 % minimum duration of a USV to be included in the analysis
        opts.min_score double = 0 % Score (confidence) of a USV to be included in the analysis
    end

    % perform various checks
    too_short = calls.Box(:,3) < opts.min_duration;
    too_low_score = calls.Score < opts.min_score;

    % Only keep calls that don't fail the above checks
    is_good = ~too_short & ~too_low_score;
    calls = calls(is_good,:);
end