function s = calc_file_performance(truth_file, test_file, opts)
% calculate perfomance for single pair of truth/test detection files
    arguments
        truth_file string = "anna" % Path to manually curated detection file
        test_file string = "brandon" % Path to network generated detected file
        opts.min_overlap double = 0.1 % minimum overlap of detection boxes to be considered matching
        opts.min_duration double = .005 % minimum duration of a USV to be included in the analysis
        opts.min_score double = 0.5 % Score (confidence) of a USV to be included in the analysis
        opts.include_rejected logical = false; % Should USVs marked as "rejected" be included in the analysis
    end

    %% load calls
    truth = load(truth_file).Calls;
    test = load(test_file).Calls;

    %% filter calls
    truth = filter_calls(truth, min_duration=opts.min_duration, min_score=opts.min_score, include_rejected=opts.include_rejected);
    test = filter_calls(test, min_duration=opts.min_duration, min_score=opts.min_score, include_rejected=opts.include_rejected);

    truth_box = truth.Box;
    test_box = test.Box;
    %% calculator confusion matrix statistics 
    s = get_confusion_from_overlap(truth_box, test_box, min_overlap=opts.min_overlap);
end



